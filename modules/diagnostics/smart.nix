{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  services.smartd = {
    enable = true;
    autodetect = true;

    notifications = {
      mail.enable = false;
      systembus-notify.enable = false;
      wall.enable = false;
      x11.enable = false;
    };
  };

  services.prometheus.exporters.smartctl = {
    enable = true;
    port = 9633;
  };

  services.prometheus.scrapeConfigs = [
    {
      job_name = "smartctl";
      static_configs = [{
        targets = [ "localhost:9633" ];
      }];
    }
  ];
}
