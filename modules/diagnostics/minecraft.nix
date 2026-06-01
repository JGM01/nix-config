{
  systemd.services.minecraft-server-minecrap = {
    unitConfig.OnFailure = [ "trollserver-incident-bundle@%n.service" ];

    serviceConfig = {
      LogsDirectory = "minecraft/minecrap";
      LogsDirectoryMode = "0750";
    };
  };
}
