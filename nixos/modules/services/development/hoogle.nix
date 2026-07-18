{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.hoogle;

  hoogleEnv = pkgs.buildEnv {
    name = "hoogle";
    paths = [ (cfg.haskellPackages.ghcWithHoogle cfg.packages) ];
  };

in
{

  options.services.hoogle = {
    enable = lib.mkEnableOption "Haskell documentation server";

    extraOptions = lib.mkOption {
      default = [ ];

      description = ''
        Additional command-line arguments to pass to
        {command}`hoogle server`
      '';

      example = [ "--no-security-headers" ];
      type = lib.types.listOf lib.types.str;
    };

    haskellPackages = lib.mkOption {
      default = pkgs.haskellPackages;
      defaultText = lib.literalExpression "pkgs.haskellPackages";
      description = "Which haskell package set to use.";
      type = lib.types.attrs;
    };

    home = lib.mkOption {
      default = "https://hoogle.haskell.org";
      description = "Url for hoogle logo";
      type = lib.types.str;
    };

    host = lib.mkOption {
      default = "127.0.0.1";
      description = "Set the host to bind on.";
      type = lib.types.str;
    };

    packages = lib.mkOption {
      default = hp: [ ];
      defaultText = lib.literalExpression "hp: []";

      description = ''
        The Haskell packages to generate documentation for.

        The option value is a function that takes the package set specified in
        the {var}`haskellPackages` option as its sole parameter and
        returns a list of packages.
      '';

      example = lib.literalExpression "hp: with hp; [ text lens ]";
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
    };

    port = lib.mkOption {
      default = 8080;

      description = ''
        Port number Hoogle will be listening to.
      '';

      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hoogle = {
      description = "Haskell documentation server";

      serviceConfig = {
        DynamicUser = true;

        ExecStart = ''
          ${hoogleEnv}/bin/hoogle server --local --port ${toString cfg.port} --home ${cfg.home} --host ${cfg.host} \
            ${lib.concatStringsSep " " cfg.extraOptions}
        '';

        ProtectHome = true;
        Restart = "always";
        RuntimeDirectory = "hoogle";
        WorkingDirectory = "%t/hoogle";
      };

      wantedBy = [ "multi-user.target" ];
    };
  };

}
