{ pkgs, ... }:

let
  incidentBundle = pkgs.writeShellApplication {
    name = "trollserver-incident-bundle";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      gawk
      gnugrep
      gnused
      procps
      smartmontools
      systemd
      gnutar
      util-linux
      zstd
    ];
    text = ''
      unit="''${1:-minecraft-server-minecrap.service}"
      timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
      root="/var/lib/trollserver-incidents"
      bundle_dir="$root/$timestamp"
      archive="$root/$timestamp.tar.zst"

      mkdir -p "$bundle_dir"
      chmod 0700 "$root" "$bundle_dir"

      run_capture() {
        local name="$1"
        shift
        {
          printf '$'
          printf ' %q' "$@"
          printf '\n\n'
          "$@"
        } > "$bundle_dir/$name" 2>&1 || true
      }

      copy_if_present() {
        local source="$1"
        local target="$2"
        if [ -e "$source" ]; then
          mkdir -p "$(dirname "$bundle_dir/$target")"
          cp -a "$source" "$bundle_dir/$target" 2>/dev/null || true
        fi
      }

      run_capture "systemctl-status.txt" systemctl status --no-pager --full "$unit"
      run_capture "journal-unit-current-boot.txt" journalctl -b -u "$unit" --no-pager --output=short-iso
      run_capture "journal-errors-current-boot.txt" journalctl -b -p warning..alert --no-pager --output=short-iso
      run_capture "kernel-current-boot.txt" journalctl -b -k --no-pager --output=short-iso
      run_capture "dmesg.txt" dmesg --human --color=never
      run_capture "coredump-metadata.txt" coredumpctl --no-pager --no-legend
      run_capture "disk-usage.txt" df -h
      run_capture "mounts.txt" findmnt
      run_capture "memory.txt" free -h
      run_capture "processes.txt" ps auxww
      run_capture "smart-summary.txt" smartctl --scan-open

      while read -r device _; do
        [ -n "$device" ] || continue
        safe_name="$(printf '%s' "$device" | sed 's#[^A-Za-z0-9._-]#_#g')"
        run_capture "smart-$safe_name.txt" smartctl -a "$device"
      done < <(smartctl --scan-open 2>/dev/null || true)

      copy_if_present "/srv/minecraft/minecrap/logs/latest.log" "minecraft/latest.log"
      if [ -d /srv/minecraft/minecrap/logs ]; then
        find /srv/minecraft/minecrap/logs -maxdepth 1 -type f -name '*.log.gz' -o -name '*.log' 2>/dev/null \
          | sort \
          | tail -n 10 \
          | while read -r log_file; do
              copy_if_present "$log_file" "minecraft/logs/$(basename "$log_file")"
            done
      fi

      if [ -d /var/log/minecraft/minecrap ]; then
        find /var/log/minecraft/minecrap -maxdepth 1 -type f \( -name 'hs_err_pid*.log' -o -name 'gc.log*' \) 2>/dev/null \
          | sort \
          | while read -r crash_file; do
              copy_if_present "$crash_file" "minecraft/jvm/$(basename "$crash_file")"
            done
      fi

      if [ -d /sys/fs/pstore ]; then
        find /sys/fs/pstore -maxdepth 1 -type f 2>/dev/null \
          | while read -r pstore_file; do
              copy_if_present "$pstore_file" "pstore/$(basename "$pstore_file")"
            done
      fi

      tar --zstd -cf "$archive" -C "$root" "$timestamp"
      chmod 0600 "$archive"
      rm -rf "$bundle_dir"

      find "$root" -maxdepth 1 -type f -name '*.tar.zst' -print \
        | sort \
        | head -n -5 \
        | xargs -r rm -f

      logger -t trollserver-incident-bundle "created $archive for $unit"
      printf '%s\n' "$archive"
    '';
  };
in
{
  environment.systemPackages = [
    incidentBundle
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/trollserver-incidents 0700 root root -"
  ];

  systemd.services."trollserver-incident-bundle@" = {
    description = "Create trollserver incident bundle for %i";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${incidentBundle}/bin/trollserver-incident-bundle %i";
    };
  };
}
