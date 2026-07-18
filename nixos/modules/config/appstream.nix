{ config, lib, ... }:
{
  options = {
    appstream.enable = lib.mkOption {
      default = true;

      description = ''
        Whether to install files to support the
        [AppStream metadata specification](https://www.freedesktop.org/software/appstream/docs/index.html).
      '';

      type = lib.types.bool;
    };
  };

  config = lib.mkIf config.appstream.enable {
    environment.pathsToLink = [
      # per component metadata
      "/share/metainfo"
      # legacy path for above
      "/share/appdata"
    ];
  };

}
