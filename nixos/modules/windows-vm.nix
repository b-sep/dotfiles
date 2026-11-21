{ config, pkgs, ... }:

# Windows VM via Docker + KVM (dockurr/windows) and FreeRDP.
#
# System prerequisites in configuration.nix:
#   - virtualisation.docker.enable = true (socket-activated on demand)
#   - boot.kernelModules = [ "kvm-amd" ]  (exposes /dev/kvm; requires SVM in BIOS)
#   - users.users.junior.extraGroups includes "docker" and "kvm"
#
# Persistence:
#   - Virtual disk & Windows state live in ~/.windows (mounted as /storage)
#   - Shared folder lives in ~/Windows (mounted as /shared -> Desktop\Shared & Z:)
#   Both are on /home (outside /nix/store), so everything installed inside
#   Windows survives nixos-rebuild, rollbacks, and garbage collection.
#   On first run, `chattr +C` disables Btrfs CoW on ~/.windows before the disk
#   image is created, avoiding CoW fragmentation on /home.
#
# Usage:
#   - Walker: search "Windows"
#   - CLI:    windows-vm [launch [-k]|install|web|stop|status|logs|remove]

let
  # Declarative VM settings (changes apply on the next VM start).
  # Version options:
  #   "11l" - Windows 11 LTSC (~4.7 GB, lean, no bloat/Store/Copilot)
  #   "11"  - Windows 11 Pro  (~7.9 GB)
  #   "10l" - Windows 10 LTSC (~4.6 GB)
  #   "10"  - Windows 10 Pro  (~5.7 GB)
  version = "11l";
  ramSize = "4G";
  cpuCores = "4";
  diskSize = "64G"; # Thin-provisioned: grows dynamically up to this limit
  timezone = "America/Sao_Paulo";
  username = "docker";
  password = "admin"; # Local-only; all ports are bound strictly to 127.0.0.1

  containerName = "windows-vm";
  image = "dockurr/windows";
  storageDir = "${config.home.homeDirectory}/.windows";
  sharedDir = "${config.home.homeDirectory}/Windows";

  composeFile = (pkgs.formats.yaml { }).generate "windows-vm-compose.yml" {
    services.windows = {
      inherit image;
      container_name = containerName;
      environment = {
        VERSION = version;
        RAM_SIZE = ramSize;
        CPU_CORES = cpuCores;
        DISK_SIZE = diskSize;
        USERNAME = username;
        PASSWORD = password;
        PROTECT = "Y";
        TZ = timezone;
        ARGUMENTS = "-rtc base=localtime,clock=host,driftfix=slew";
      };
      devices = [
        "/dev/kvm"
        "/dev/net/tun"
      ];
      cap_add = [ "NET_ADMIN" ];
      ports = [
        "127.0.0.1:8006:8006"
        "127.0.0.1:3389:3389/tcp"
        "127.0.0.1:3389:3389/udp"
      ];
      volumes = [
        "${storageDir}:/storage"
        "${sharedDir}:/shared"
      ];
      restart = "no";
      stop_grace_period = "2m";
    };
  };

  # FreeRDP 3 tries Kerberos before NTLM for NLA. Pointing it at a realm-less
  # config lets it fall straight through to NTLM for the local Windows account
  # instead of stalling on DNS/KDC timeouts when offline.
  krb5Conf = pkgs.writeText "windows-vm-krb5.conf" ''
    [libdefaults]
      dns_lookup_kdc = false
      dns_lookup_realm = false
  '';

  windowsIcon = pkgs.writeText "windows-vm.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
      <rect x="4" y="4" width="26" height="26" rx="3" fill="#00a4ef"/>
      <rect x="34" y="4" width="26" height="26" rx="3" fill="#00a4ef"/>
      <rect x="4" y="34" width="26" height="26" rx="3" fill="#00a4ef"/>
      <rect x="34" y="34" width="26" height="26" rx="3" fill="#00a4ef"/>
    </svg>
  '';

  windows-vm = pkgs.writeShellApplication {
    name = "windows-vm";
    runtimeInputs = with pkgs; [
      coreutils
      docker
      e2fsprogs
      freerdp
      gawk
      gnugrep
      hyprland
      jq
      libnotify
      util-linux
      xdg-utils
    ];
    text = ''
      COMPOSE_FILE="${composeFile}"
      CONTAINER="${containerName}"
      STORAGE_DIR="${storageDir}"
      SHARED_DIR="${sharedDir}"
      WIN_USER="${username}"
      WIN_PASS="${password}"
      KRB5_CONF="${krb5Conf}"
      LOCK_FILE="''${XDG_RUNTIME_DIR:-/run/user/$UID}/windows-vm.lock"

      dc() {
        docker compose -p windows-vm -f "$COMPOSE_FILE" "$@"
      }

      notify() {
        notify-send -a "Windows VM" -i windows-vm "$@" 2>/dev/null || true
      }

      check_kvm() {
        if [[ ! -e /dev/kvm ]]; then
          msg="/dev/kvm não encontrado. Rode nixos-rebuild switch, reinicie e verifique se SVM (AMD-V) está habilitado na BIOS."
          echo "Erro: $msg" >&2
          notify -u critical "KVM indisponível" "$msg"
          exit 1
        fi
      }

      prepare_dirs() {
        if [[ ! -d "$STORAGE_DIR" ]]; then
          mkdir -p "$STORAGE_DIR"
          chmod 0700 "$STORAGE_DIR"
          # Disable CoW on Btrfs before the VM disk image is created.
          chattr +C "$STORAGE_DIR" 2>/dev/null || true
        fi
        mkdir -p "$SHARED_DIR"
      }

      has_disk_image() {
        [[ -s "$STORAGE_DIR/data.img" || -s "$STORAGE_DIR/data.qcow2" ]]
      }

      container_status() {
        docker inspect --format='{{.State.Status}}' "$CONTAINER" 2>/dev/null || true
      }

      rdp_auth_check() {
        KRB5_CONFIG="$KRB5_CONF" xfreerdp /args-from:stdin >/dev/null 2>&1 <<EOF
      /u:$WIN_USER
      /p:$WIN_PASS
      /v:127.0.0.1:3389
      /cert:ignore
      /timeout:2000
      +auth-only
      EOF
      }

      wait_for_rdp() {
        local started_at status count=0

        # Wait until dockurr/windows reports the VM booted (or container exits)
        while true; do
          status=$(container_status)
          if [[ "$status" != "running" ]]; then
            echo "Erro: container '$CONTAINER' parou inesperadamente (status: ''${status:-ausente})." >&2
            return 1
          fi

          started_at=$(docker inspect --format='{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || true)
          if [[ -n "$started_at" ]] && docker logs --since "$started_at" "$CONTAINER" 2>&1 | grep -qi "windows started successfully"; then
            break
          fi

          sleep 1
          ((++count > 120)) && {
            echo "Timeout aguardando o boot da VM. Veja http://127.0.0.1:8006 ou 'windows-vm logs'." >&2
            return 1
          }
        done

        # Probe RDP until Windows finishes booting and starts TermService
        count=0
        while ! rdp_auth_check; do
          status=$(container_status)
          if [[ "$status" != "running" ]]; then
            return 1
          fi
          sleep 1
          ((++count > 90)) && {
            echo "Timeout aguardando o serviço RDP do Windows. Se a instalação inicial ainda estiver em andamento, acompanhe em http://127.0.0.1:8006." >&2
            return 1
          }
        done
      }

      open_rdp() {
        local hypr_scale scale_percent rdp_scale=""
        hypr_scale=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | .scale' 2>/dev/null || echo "1")
        scale_percent=$(awk -v s="''${hypr_scale:-1}" 'BEGIN { printf "%d", s * 100 }')

        if ((scale_percent >= 170)); then
          rdp_scale="/scale:180"
        elif ((scale_percent >= 130)); then
          rdp_scale="/scale:140"
        fi

        local rdp_args=(
          "/u:$WIN_USER"
          "/p:$WIN_PASS"
          /v:127.0.0.1:3389
          -grab-keyboard
          /sound
          /microphone
          /clipboard
          /cert:ignore
          "/title:Windows VM"
          +dynamic-resolution
          /gfx:AVC444
          "/floatbar:sticky:off,default:visible,show:fullscreen"
        )
        if [[ -n "$rdp_scale" ]]; then
          rdp_args+=("$rdp_scale")
        fi

        # Pass credentials via stdin so /proc/<pid>/cmdline never exposes them.
        printf '%s\n' "''${rdp_args[@]}" | KRB5_CONFIG="$KRB5_CONF" xfreerdp /args-from:stdin || true
      }

      cmd_install() {
        check_kvm
        prepare_dirs

        echo "Iniciando instalação da Windows VM (versão ${version}, ${ramSize} RAM, ${cpuCores} cores, disco ${diskSize})..."
        echo "A imagem do Windows será baixada e instalada automaticamente."
        dc up -d

        notify -t 10000 "Instalando Windows VM" \
          "Acompanhe em http://127.0.0.1:8006 (senha: $WIN_PASS). Quando o desktop aparecer, abra o Windows no Walker."
        sleep 3
        xdg-open "http://127.0.0.1:8006" >/dev/null 2>&1 &

        echo ""
        echo "Acompanhe o progresso em: http://127.0.0.1:8006 (senha: $WIN_PASS)"
        echo "Quando o desktop do Windows aparecer, feche a aba e abra 'Windows' no Walker (ou rode 'windows-vm launch')."
      }

      cmd_launch() {
        local keep_alive=false
        if [[ "''${1:-}" == "--keep-alive" || "''${1:-}" == "-k" ]]; then
          keep_alive=true
        fi

        exec {lock_fd}>"$LOCK_FILE"
        if ! flock -n "$lock_fd"; then
          notify -t 3000 "Windows VM" "Já existe uma sessão sendo iniciada ou aberta."
          exit 0
        fi

        check_kvm
        prepare_dirs

        # First-time run: trigger automated install and open the web viewer
        if ! has_disk_image; then
          cmd_install
          exit 0
        fi

        if [[ "$(container_status)" != "running" ]]; then
          notify -t 5000 "Windows VM" "Iniciando Windows..."
          dc up -d
        fi

        if ! wait_for_rdp; then
          notify -u critical "Windows VM" \
            "RDP não respondeu a tempo. Se ainda estiver instalando/atualizando, rode 'windows-vm web'."
          exit 1
        fi

        open_rdp

        if [[ "$keep_alive" == "false" ]]; then
          notify -t 4000 "Windows VM" "Desligando Windows..."
          dc down
          notify -t 3000 "Windows VM" "Windows desligado."
        else
          echo "Sessão RDP encerrada. VM mantida ligada (pare com: windows-vm stop)."
        fi
      }

      cmd_web() {
        check_kvm
        prepare_dirs
        if [[ "$(container_status)" != "running" ]]; then
          dc up -d
          sleep 3
        fi
        xdg-open "http://127.0.0.1:8006" >/dev/null 2>&1 &
        echo "Abrindo console web em http://127.0.0.1:8006 (senha: $WIN_PASS)"
      }

      cmd_stop() {
        echo "Desligando Windows VM..."
        dc down
        echo "Windows VM desligada."
      }

      cmd_status() {
        local status size
        status=$(container_status)
        if [[ -d "$STORAGE_DIR" ]]; then
          size=$(du -sh "$STORAGE_DIR" 2>/dev/null | cut -f1)
        else
          size="não instalado"
        fi

        echo "Status:      ''${status:-parada}"
        echo "Versão:      ${version} (${ramSize} RAM, ${cpuCores} cores, disco máx. ${diskSize})"
        echo "Disco:       $STORAGE_DIR ($size)"
        echo "Compartilh.: $SHARED_DIR (Z: no Windows)"
        echo "Web UI:      http://127.0.0.1:8006 (senha: $WIN_PASS)"
        echo "RDP:         127.0.0.1:3389 (usuário: $WIN_USER)"
      }

      cmd_logs() {
        docker logs -f "$CONTAINER"
      }

      cmd_remove() {
        echo "Isso vai apagar o disco virtual do Windows ($STORAGE_DIR) e todos os programas instalados nele."
        echo "A pasta compartilhada ($SHARED_DIR) NÃO será removida."
        read -r -p "Deseja continuar? [s/N] " reply
        if [[ ! "$reply" =~ ^[sSyY]$ ]]; then
          echo "Cancelado."
          exit 0
        fi
        dc down 2>/dev/null || true
        rm -rf -- "$STORAGE_DIR"
        echo "Windows VM removida."
      }

      show_usage() {
        cat <<'EOF'
      Uso: windows-vm <comando> [opções]

      Comandos:
        launch [-k|--keep-alive]  Inicia a VM e conecta via RDP (desliga ao fechar, salvo com -k)
        install                   Inicia a instalação inicial e abre o console web (127.0.0.1:8006)
        web                       Abre o console web da VM no navegador (127.0.0.1:8006)
        stop                      Desliga a VM graciosamente (ACPI)
        status                    Mostra status, uso de disco e endereços
        logs                      Acompanha os logs do container
        remove                    Para a VM e apaga ~/.windows (mantém ~/Windows)
      EOF
      }

      case "''${1:-launch}" in
        launch)  shift || true; cmd_launch "$@" ;;
        install) cmd_install ;;
        web)     cmd_web ;;
        stop)    cmd_stop ;;
        status)  cmd_status ;;
        logs)    cmd_logs ;;
        remove)  cmd_remove ;;
        -h|--help|help) show_usage ;;
        *) show_usage >&2; exit 1 ;;
      esac
    '';
  };
in
{
  home.packages = [ windows-vm ];

  xdg.dataFile."icons/hicolor/scalable/apps/windows-vm.svg".source = windowsIcon;

  xdg.desktopEntries.windows-vm = {
    name = "Windows";
    genericName = "Windows Virtual Machine";
    comment = "Run Windows VM via Docker/KVM and connect with RDP";
    exec = "${windows-vm}/bin/windows-vm launch";
    icon = "windows-vm";
    terminal = false;
    categories = [ "System" "Emulator" ];
  };
}
