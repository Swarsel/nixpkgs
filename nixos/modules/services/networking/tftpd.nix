{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = {
    services.tftpd.enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable tftpd, a Trivial File Transfer Protocol server.
        The server will be run as an xinetd service.
      '';

      type = lib.types.bool;
    };

    services.tftpd.path = lib.mkOption {
      default = "/srv/tftp";

      description = ''
        Where the tftp server files are stored.
      '';

      type = lib.types.path;
    };
  };

  config = lib.mkIf config.services.tftpd.enable {
    services.xinetd.enable = true;

    services.xinetd.services = lib.singleton {
      name = "tftp";
      protocol = "udp";
      server = "${pkgs.netkittftp}/sbin/in.tftpd";
      serverArgs = "${config.services.tftpd.path}";
    };
  };
}
