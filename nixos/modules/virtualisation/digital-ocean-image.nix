{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.virtualisation.digitalOceanImage;
in
{

  imports = [
    ./digital-ocean-config.nix
    ./disk-size-option.nix
    ../image/file-options.nix
    (lib.mkRenamedOptionModuleWith {
      from = [
        "virtualisation"
        "digitalOceanImage"
        "diskSize"
      ];

      sinceRelease = 2411;

      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options = {
    virtualisation.digitalOceanImage.compressionMethod = mkOption {
      default = "gzip";

      description = ''
        Disk image compression method. Choose bzip2 to generate smaller images that
        take longer to generate but will consume less metered storage space on your
        Digital Ocean account.
      '';

      example = "bzip2";

      type = types.enum [
        "gzip"
        "bzip2"
      ];
    };

    virtualisation.digitalOceanImage.configFile = mkOption {
      default = null;

      description = ''
        A path to a configuration file which will be placed at
        `/etc/nixos/configuration.nix` and be used when switching
        to a new configuration. If set to `null`, a default
        configuration is used that imports
        `(modulesPath + "/virtualisation/digital-ocean-config.nix")`.
      '';

      type = with types; nullOr path;
    };
  };

  #### implementation
  config =
    let
      format = "qcow2";
    in
    {
      image.extension = lib.concatStringsSep "." [
        format
        (
          {
            "bzip2" = "bz2";
            "gzip" = "gz";
          }
          .${cfg.compressionMethod}
        )
      ];

      system.build.digitalOceanImage = import ../../lib/make-disk-image.nix {
        inherit (config.image) baseName;
        inherit (config.virtualisation) diskSize;

        inherit
          config
          lib
          pkgs
          format
          ;

        configFile =
          if cfg.configFile == null then
            config.virtualisation.digitalOcean.defaultConfigFile
          else
            cfg.configFile;

        name = "digital-ocean-image";

        postVM =
          let
            compress =
              {
                "bzip2" = "${pkgs.bzip2}/bin/bzip2";
                "gzip" = "${pkgs.gzip}/bin/gzip";
              }
              .${cfg.compressionMethod};
          in
          ''
            ${compress} $diskImage
          '';
      };

      system.build.image = config.system.build.digitalOceanImage;
      system.nixos.tags = [ "digital-ocean" ];

    };

  meta.maintainers = with maintainers; [
    arianvp
    eamsden
  ];

}
