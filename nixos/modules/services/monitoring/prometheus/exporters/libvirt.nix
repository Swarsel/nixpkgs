{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.prometheus.exporters.libvirt;
in
{
  extraOpts = {
    libvirtUri = lib.mkOption {
      default = "qemu:///system";
      description = "Libvirt URI from which to extract metrics";
      type = lib.types.str;
    };
  };

  port = 9177;

  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${lib.getExe pkgs.prometheus-libvirt-exporter} \
        --web.listen-address ${cfg.listenAddress}:${toString cfg.port} \
        --libvirt.uri ${cfg.libvirtUri} ${lib.concatStringsSep " " cfg.extraFlags}
      '';

      RestrictAddressFamilies = [
        "AF_UNIX"
        "AF_INET"
        "AF_INET6"
      ];
    };
  };
}
