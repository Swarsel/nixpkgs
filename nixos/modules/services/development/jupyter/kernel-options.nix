# Options that can be used for creating a jupyter kernel.
{ lib, pkgs }:
{
  options = {

    argv = lib.mkOption {
      description = ''
        Command and arguments to start the kernel.
      '';

      example = [
        "{customEnv.interpreter}"
        "-m"
        "ipykernel_launcher"
        "-f"
        "{connection_file}"
      ];

      type = lib.types.listOf lib.types.str;
    };

    displayName = lib.mkOption {
      default = "";

      description = ''
        Name that will be shown to the user.
      '';

      example = lib.literalExpression ''
        "Python 3"
        "Python 3 for Data Science"
      '';

      type = lib.types.str;
    };

    env = lib.mkOption {
      default = { };

      description = ''
        Environment variables to set for the kernel.
      '';

      example = {
        OMP_NUM_THREADS = "1";
      };

      type = lib.types.attrsOf lib.types.str;
    };

    extraPaths = lib.mkOption {
      default = { };

      description = ''
        Extra paths to link in kernel directory
      '';

      example = lib.literalExpression ''"{ examples = ''${env.sitePack}/IRkernel/kernelspec/kernel.js"; }'';
      type = lib.types.attrsOf lib.types.path;
    };

    language = lib.mkOption {
      description = ''
        Language of the environment. Typically the name of the binary.
      '';

      example = "python";
      type = lib.types.str;
    };

    logo32 = lib.mkOption {
      default = null;

      description = ''
        Path to 32x32 logo png.
      '';

      example = lib.literalExpression ''"''${env.sitePackages}/ipykernel/resources/logo-32x32.png"'';
      type = lib.types.nullOr lib.types.path;
    };

    logo64 = lib.mkOption {
      default = null;

      description = ''
        Path to 64x64 logo png.
      '';

      example = lib.literalExpression ''"''${env.sitePackages}/ipykernel/resources/logo-64x64.png"'';
      type = lib.types.nullOr lib.types.path;
    };
  };

  freeformType = (pkgs.formats.json { }).type;
}
