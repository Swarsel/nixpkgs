{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hardware.lcd;
  pkg = lib.getBin pkgs.lcdproc;

  serverCfg = pkgs.writeText "lcdd.conf" ''
    [server]
    DriverPath=${pkg}/lib/lcdproc/
    ReportToSyslog=false
    Bind=${cfg.serverHost}
    Port=${toString cfg.serverPort}
    ${cfg.server.extraConfig}
  '';

  clientCfg = pkgs.writeText "lcdproc.conf" ''
    [lcdproc]
    Server=${cfg.serverHost}
    Port=${toString cfg.serverPort}
    ReportToSyslog=false
    ${cfg.client.extraConfig}
  '';

  serviceCfg = {
    DynamicUser = true;
    Restart = "on-failure";
    Slice = "lcd.slice";
  };

in
with lib;
{

  options = with types; {
    services.hardware.lcd = {
      client = {
        enable = mkOption {
          default = false;
          description = "Enable the LCD panel client (LCDproc)";
          type = bool;
        };

        extraConfig = mkOption {
          default = "";
          description = "Additional configuration added verbatim to the client config.";
          type = lines;
        };

        restartForever = mkOption {
          default = true;
          description = "Try restarting the client forever.";
          type = bool;
        };
      };

      server = {
        enable = mkOption {
          default = false;
          description = "Enable the LCD panel server (LCDd)";
          type = bool;
        };

        extraConfig = mkOption {
          default = "";
          description = "Additional configuration added verbatim to the server config.";
          type = lines;
        };

        openPorts = mkOption {
          default = false;
          description = "Open the ports in the firewall";
          type = bool;
        };

        usbGroup = mkOption {
          default = "dialout";
          description = "The group to use for settings permissions. This group must exist or you will have to create it.";
          type = str;
        };

        usbPermissions = mkOption {
          default = false;

          description = ''
            Set group-write permissions on a USB device.

            A USB connected LCD panel will most likely require having its
            permissions modified for lcdd to write to it. Enabling this option
            sets group-write permissions on the device identified by
            {option}`services.hardware.lcd.usbVid` and
            {option}`services.hardware.lcd.usbPid`. In order to find the
            values, you can run the {command}`lsusb` command. Example
            output:

            ```
            Bus 005 Device 002: ID 0403:c630 Future Technology Devices International, Ltd lcd2usb interface
            ```

            In this case the vendor id is 0403 and the product id is c630.
          '';

          type = bool;
        };

        usbPid = mkOption {
          default = "";
          description = "The product ID of the USB device to claim.";
          type = str;
        };

        usbVid = mkOption {
          default = "";
          description = "The vendor ID of the USB device to claim.";
          type = str;
        };
      };

      serverHost = mkOption {
        default = "localhost";
        description = "Host on which LCDd is listening.";
        type = str;
      };

      serverPort = mkOption {
        default = 13666;
        description = "Port on which LCDd is listening.";
        type = int;
      };
    };
  };

  config = mkIf (cfg.server.enable || cfg.client.enable) {
    networking.firewall.allowedTCPPorts = mkIf (cfg.server.enable && cfg.server.openPorts) [
      cfg.serverPort
    ];

    services.udev.extraRules = mkIf (cfg.server.enable && cfg.server.usbPermissions) ''
      ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="${cfg.server.usbVid}", ATTRS{idProduct}=="${cfg.server.usbPid}", MODE="660", GROUP="${cfg.server.usbGroup}"
    '';

    systemd.services = {
      lcdd = mkIf cfg.server.enable {
        description = "LCDproc - server";

        serviceConfig = serviceCfg // {
          ExecStart = "${pkg}/bin/LCDd -f -c ${serverCfg}";
          SupplementaryGroups = cfg.server.usbGroup;
        };

        wantedBy = [ "lcd.target" ];
      };

      lcdproc = mkIf cfg.client.enable {
        after = [ "lcdd.service" ];
        description = "LCDproc - client";

        serviceConfig = serviceCfg // {
          ExecStart = "${pkg}/bin/lcdproc -f -c ${clientCfg}";
          # If the server is being restarted at the same time, the client will
          # fail as it cannot connect, so space it out a bit.
          RestartSec = "5";
        };

        # Allow restarting for eternity
        startLimitIntervalSec = lib.mkIf cfg.client.restartForever 0;
        wantedBy = [ "lcd.target" ];
      };
    };

    systemd.targets.lcd = {
      after = [
        "lcdd.service"
        "lcdproc.service"
      ];

      description = "LCD client/server";
      wantedBy = [ "multi-user.target" ];
    };
  };

  meta.maintainers = with maintainers; [ peterhoeg ];
}
