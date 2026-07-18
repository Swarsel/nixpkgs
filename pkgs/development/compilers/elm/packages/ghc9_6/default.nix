{
  lib,
  fetchElmDeps,
  makeWrapper,
  nodejs,
  pkgs,
}:

self:
pkgs.haskell.packages.ghc96.override {
  overrides =
    self: super:
    let
      inherit (pkgs.haskell.lib.compose) overrideCabal;
      elmPkgs = rec {
        inherit fetchElmDeps;

        elm = overrideCabal (drv: {
          preConfigure = fetchElmDeps {
            elmPackages = (import ../elm-srcs.nix);
            elmVersion = drv.version;
            registryDat = ../../registry.dat;
          };

          postInstall = ''
            wrapProgram $out/bin/elm \
              --prefix PATH ':' ${lib.makeBinPath [ nodejs ]}
          '';

          buildTools = drv.buildTools or [ ] ++ [ makeWrapper ];
          description = "Delightful language for reliable webapps";
          # sadly with parallelism most of the time breaks compilation
          enableParallelBuilding = false;
          homepage = "https://elm-lang.org/";
          license = lib.licenses.bsd3;

          maintainers = with lib.maintainers; [
            turbomack
          ];
        }) (self.callPackage ./elm { });

        elmVersion = elmPkgs.elm.version;
      };
    in
    elmPkgs
    // {
      inherit elmPkgs;

      ansi-wl-pprint = overrideCabal (drv: {
        jailbreak = true;
      }) (self.callPackage ./ansi-wl-pprint { });
    };
}
