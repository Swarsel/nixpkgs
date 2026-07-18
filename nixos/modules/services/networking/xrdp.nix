{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xrdp;

  confDir = pkgs.runCommand "xrdp.conf" { preferLocalBuild = true; } ''
    mkdir -p $out

    cp -r ${cfg.package}/etc/xrdp/* $out
    chmod -R +w $out

    cat > $out/startwm.sh <<EOF
    #!/bin/sh
    . /etc/profile
    ${lib.optionalString cfg.audio.enable "${cfg.audio.package}/libexec/pulseaudio-xrdp-module/pulseaudio_xrdp_init"}
    ${cfg.defaultWindowManager}
    EOF
    chmod +x $out/startwm.sh

    substituteInPlace $out/xrdp.ini \
      --replace-fail "#rsakeys_ini=" "rsakeys_ini=/run/xrdp/rsakeys.ini" \
      --replace-fail "certificate=" "certificate=${cfg.sslCert}" \
      --replace-fail "key_file=" "key_file=${cfg.sslKey}" \
      --replace-fail LogFile=xrdp.log LogFile=/dev/null \
      --replace-fail EnableSyslog=true EnableSyslog=false

    substituteInPlace $out/sesman.ini \
      --replace-fail LogFile=xrdp-sesman.log LogFile=/dev/null \
      --replace-fail EnableSyslog=true EnableSyslog=false \
      --replace-fail startwm.sh $out/startwm.sh \
      --replace-fail reconnectwm.sh $out/reconnectwm.sh \

    # Ensure that clipboard works for non-ASCII characters
    sed -i -e '/.*SessionVariables.*/ a\
    LANG=${config.i18n.defaultLocale}${
      lib.optionalString (config.i18n.glibcLocales != null) ''
        \
        LOCALE_ARCHIVE=${config.i18n.glibcLocales}/lib/locale/locale-archive
      ''
    }
    ' $out/sesman.ini

    ${cfg.extraConfDirCommands}
  '';
in
{

  ###### interface

  options = {

    services.xrdp = {

      enable = mkEnableOption "xrdp, the Remote Desktop Protocol server";
      package = mkPackageOption pkgs "xrdp" { };

      audio = {
        enable = mkEnableOption "audio support for xrdp sessions. So far it only works with PulseAudio sessions on the server side. No PipeWire support yet";
        package = mkPackageOption pkgs "pulseaudio-module-xrdp" { };
      };

      confDir = mkOption {
        default = confDir;

        description = ''
          Configuration directory of xrdp and sesman.

          Changes to this must be made through extraConfDirCommands.
        '';

        internal = true;
        readOnly = true;
        type = types.path;
      };

      defaultWindowManager = mkOption {
        default = "xterm";

        description = ''
          The script to run when user log in, usually a window manager, e.g. "icewm", "xfce4-session"
          This is per-user overridable, if file ~/startwm.sh exists it will be used instead.
        '';

        example = "xfce4-session";
        type = types.str;
      };

      extraConfDirCommands = mkOption {
        default = "";

        description = ''
          Extra commands to run on the default confDir derivation.
        '';

        example = ''
          substituteInPlace $out/sesman.ini \
            --replace-fail LogLevel=INFO LogLevel=DEBUG \
            --replace-fail LogFile=/dev/null LogFile=/var/log/xrdp.log
        '';

        type = types.str;
      };

      openFirewall = mkOption {
        default = false;
        description = "Whether to open the firewall for the specified RDP port.";
        type = types.bool;
      };

      port = mkOption {
        default = 3389;

        description = ''
          Specifies on which port the xrdp daemon listens.
        '';

        type = types.port;
      };

      sslCert = mkOption {
        default = "/etc/xrdp/cert.pem";

        description = ''
          ssl certificate path
          A self-signed certificate will be generated if file not exists.
        '';

        example = "/path/to/your/cert.pem";
        type = types.str;
      };

      sslKey = mkOption {
        default = "/etc/xrdp/key.pem";

        description = ''
          ssl private key path
          A self-signed certificate will be generated if file not exists.
        '';

        example = "/path/to/your/key.pem";
        type = types.str;
      };
    };
  };

  ###### implementation

  config = lib.mkMerge [
    (mkIf cfg.audio.enable {
      environment.systemPackages = [ cfg.audio.package ]; # needed for autostart
      services.pulseaudio.extraModules = [ cfg.audio.package ];
    })

    (mkIf cfg.enable {

      environment.etc."xrdp".source = "${confDir}/*";
      fonts.enableDefaultPackages = mkDefault true;
      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

      security.pam.services.xrdp-sesman = {
        allowNullPassword = true;
        startSession = true;
      };

      systemd = {
        services.xrdp = {
          after = [ "network.target" ];
          description = "xrdp daemon";

          preStart = ''
            # prepare directory for unix sockets (the sockets will be owned by loggedinuser:xrdp)
            mkdir -p /tmp/.xrdp || true
            chown xrdp:xrdp /tmp/.xrdp
            chmod 3777 /tmp/.xrdp

            # generate a self-signed certificate
            if [ ! -s ${cfg.sslCert} -o ! -s ${cfg.sslKey} ]; then
              mkdir -p $(dirname ${cfg.sslCert}) || true
              mkdir -p $(dirname ${cfg.sslKey}) || true
              ${lib.getExe pkgs.openssl} req -x509 -newkey rsa:2048 -sha256 -nodes -days 365 \
                -subj /C=US/ST=CA/L=Sunnyvale/O=xrdp/CN=www.xrdp.org \
                -config ${cfg.package}/share/xrdp/openssl.conf \
                -keyout ${cfg.sslKey} -out ${cfg.sslCert}
              chown root:xrdp ${cfg.sslKey} ${cfg.sslCert}
              chmod 440 ${cfg.sslKey} ${cfg.sslCert}
            fi
            if [ ! -s /run/xrdp/rsakeys.ini ]; then
              mkdir -p /run/xrdp
              ${pkgs.xrdp}/bin/xrdp-keygen xrdp /run/xrdp/rsakeys.ini
            fi
          '';

          requires = [ "xrdp-sesman.service" ];

          serviceConfig = {
            ExecStart = "${pkgs.xrdp}/bin/xrdp --nodaemon --port ${toString cfg.port} --config ${confDir}/xrdp.ini";
            Group = "xrdp";
            PermissionsStartOnly = true;
            User = "xrdp";
          };

          wantedBy = [ "multi-user.target" ];
        };

        services.xrdp-sesman = {
          after = [ "network.target" ];
          description = "xrdp session manager";
          restartIfChanged = false; # do not restart on "nixos-rebuild switch". like "display-manager", it can have many interactive programs as children

          serviceConfig = {
            ExecStart = "${pkgs.xrdp}/bin/xrdp-sesman --nodaemon --config ${confDir}/sesman.ini";
            ExecStop = "${pkgs.coreutils}/bin/kill -INT $MAINPID";
          };

          wantedBy = [ "multi-user.target" ];
        };

      };

      users.groups.xrdp = { };

      users.users.xrdp = {
        description = "xrdp daemon user";
        group = "xrdp";
        isSystemUser = true;
      };

      # xrdp can run X11 program even if "services.xserver.enable = false"
      xdg = {
        autostart.enable = true;
        icons.enable = true;
        menus.enable = true;
        mime.enable = true;
      };

    })
  ];

}
