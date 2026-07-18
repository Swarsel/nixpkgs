{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.image = {
    baseName = lib.mkOption {
      default = "nixos-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";
      defaultText = lib.literalExpression "nixos-image-\${config.system.nixos.label}-\${pkgs.stdenv.hostPlatform.system}";

      description = ''
        Basename of the image filename without any extension (e.g. `image_1`).
      '';

      type = lib.types.str;
    };

    extension = lib.mkOption {
      description = ''
        Extension of the image filename (e.g. `raw`).
      '';

      type = lib.types.str;
    };

    # FIXME: this should be marked readOnly, when there are no
    # mkRenamedOptionModuleWith calls with `image.fileName` as
    # as a target left anymore (i.e. 24.11). We can't do it
    # before, as some source options where writable before.
    # Those should use image.baseName and image.extension instead.
    fileName = lib.mkOption {
      default = "${config.image.baseName}.${config.image.extension}";
      defaultText = lib.literalExpression "\${config.image.baseName}.\${config.image.extension}";

      description = ''
        Filename of the image including all extensions (e.g `image_1.raw` or
        `image_1.raw.zst`).
      '';

      type = lib.types.str;
    };

    filePath = lib.mkOption {
      default = config.image.fileName;
      defaultText = lib.literalExpression "config.image.fileName";

      description = ''
        Path of the image, relative to `$out` in `system.build.image`.
        While it defaults to `config.image.fileName`, it can be different for builders where
        the image is in sub directory, such as `iso`, `sd-card` or `kexec` images.
      '';

      type = lib.types.str;
    };
  };
}
