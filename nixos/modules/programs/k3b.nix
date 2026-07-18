{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.k3b = {
    enable = lib.mkOption {
      default = false;

      description = ''
        Whether to enable k3b, the KDE disk burning application.

        Additionally to installing `k3b` enabling this will
        add `setuid` wrappers in `/run/wrappers/bin`
        for both `cdrdao` and `cdrecord`. On first
        run you must manually configure the path of `cdrdae` and
        `cdrecord` to correspond to the appropriate paths under
        `/run/wrappers/bin` in the "Setup External Programs" menu.
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.programs.k3b.enable {

    environment.systemPackages = with pkgs; [
      kdePackages.k3b
      dvdplusrwtools
      cdrdao
      cdrtools
    ];

    security.wrappers = {
      cdrdao = {
        group = "cdrom";
        owner = "root";
        permissions = "u+wrx,g+x";
        setuid = true;
        source = "${pkgs.cdrdao}/bin/cdrdao";
      };

      cdrecord = {
        group = "cdrom";
        owner = "root";
        permissions = "u+wrx,g+x";
        setuid = true;
        source = "${pkgs.cdrtools}/bin/cdrecord";
      };
    };

  };
}
