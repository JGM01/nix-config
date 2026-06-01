{
  services.journald.storage = "persistent";

  services.journald.extraConfig = ''
    Compress=yes
    SystemMaxUse=512M
    RuntimeMaxUse=128M
    SystemKeepFree=2G
    MaxRetentionSec=7day
    MaxFileSec=1day
  '';
}
