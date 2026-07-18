{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.services.ihaskell;
  ihaskell = pkgs.ihaskell.override {
    packages = cfg.extraPackages;
  };

in

{
  options = {
    services.ihaskell = {
      enable = lib.mkOption {
        default = false;
        description = "Autostart an IHaskell notebook service.";
        type = lib.types.bool;
      };

      extraPackages = lib.mkOption {
        default = haskellPackages: [ ];
        defaultText = lib.literalExpression "haskellPackages: []";

        description = ''
          Extra packages available to ghc when running ihaskell. The
          value must be a function which receives the attrset defined
          in {var}`haskellPackages` as the sole argument.
        '';

        example = lib.literalExpression ''
          haskellPackages: [
            haskellPackages.wreq
            haskellPackages.lens
          ]
        '';

        type = lib.types.functionTo (lib.types.listOf lib.types.package);
      };
    };
  };

  config = lib.mkIf cfg.enable {

    systemd.services.ihaskell = {
      after = [ "network.target" ];
      description = "IHaskell notebook instance";

      serviceConfig = {
        ExecStart = "${pkgs.runtimeShell} -c \"cd $HOME;${ihaskell}/bin/ihaskell-notebook\"";
        Group = config.users.groups.ihaskell.name;
        User = config.users.users.ihaskell.name;
      };

      wantedBy = [ "multi-user.target" ];
    };

    users.groups.ihaskell.gid = config.ids.gids.ihaskell;

    users.users.ihaskell = {
      createHome = true;
      description = "IHaskell user";
      group = config.users.groups.ihaskell.name;
      home = "/var/lib/ihaskell";
      uid = config.ids.uids.ihaskell;
    };
  };
}
