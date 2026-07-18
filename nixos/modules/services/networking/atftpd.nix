# NixOS module for atftpd TFTP server
{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.atftpd;

in

{

  options = {

    services.atftpd = {

      enable = lib.mkOption {
        default = false;

        description = ''
          Whether to enable the atftpd TFTP server. By default, the server
          binds to address 0.0.0.0.
        '';

        type = lib.types.bool;
      };

      extraOptions = lib.mkOption {
        default = [ ];

        description = ''
          Extra command line arguments to pass to atftp.
        '';

        example = lib.literalExpression ''
          [ "--bind-address 192.168.9.1"
            "--verbose=7"
          ]
        '';

        type = lib.types.listOf lib.types.str;
      };

      root = lib.mkOption {
        default = "/srv/tftp";

        description = ''
          Document root directory for the atftpd.
        '';

        type = lib.types.path;
      };

    };

  };

  config = lib.mkIf cfg.enable {

    systemd.services.atftpd = {
      after = [ "network.target" ];
      description = "TFTP Server";
      # runs as nobody
      serviceConfig.ExecStart = "${pkgs.atftp}/sbin/atftpd --daemon --no-fork ${lib.concatStringsSep " " cfg.extraOptions} ${cfg.root}";
      wantedBy = [ "multi-user.target" ];
    };

  };

}
