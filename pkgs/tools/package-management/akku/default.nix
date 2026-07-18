{
  lib,
  fetchurl,
  newScope,
}:
lib.makeScope newScope (self: rec {
  akku = self.callPackage ./akku.nix { };
  akkuDerivation = self.callPackage ./akkuDerivation.nix { };

  akkuPackages =
    let
      overrides = self.callPackage ./overrides.nix { };
      makeAkkuPackage =
        akkuself: pname:
        {
          dependencies,
          dev-dependencies,
          license,
          sha256,
          source,
          url,
          version,
          homepage ? null,
          synopsis ? null,
          ...
        }:
        (akkuDerivation {
          inherit version;
          pname = "akku-${pname}";

          src = fetchurl {
            inherit url sha256;
          };

          nativeBuildInputs = map (x: akkuself.${x}) dev-dependencies;
          buildInputs = map (x: akkuself.${x}) dependencies;
          r7rs = source == "snow-fort";
          unpackPhase = "tar xf $src";

          meta = {
            license =
              let
                stringToLicense =
                  s:
                  (
                    lib.licenses
                    // (with lib.licenses; {
                      "0bsd" = bsd0;
                      "agpl" = agpl3Only;
                      "apache-2.0" = asl20;
                      "artistic" = artistic2;
                      "bsd" = bsd3;
                      "bsd-1-clause" = bsd1;
                      "bsd-2-clause" = bsd2;
                      "bsd-3-clause" = bsd3;
                      "cc0-1.0" = cc0;
                      "gpl" = gpl3Only;
                      "gpl-2" = gpl2Only;
                      "gpl-2.0-or-later" = gpl2Plus;
                      "gpl-3" = gpl3Only;
                      "gpl-3.0" = gpl3Only;
                      "gpl-3.0-or-later" = gpl3Plus;
                      "gplv2" = gpl2Only;
                      "gplv3" = gpl3Only;
                      "lgpl" = lgpl3Only;
                      "lgpl-2" = lgpl2Only;
                      "lgpl-2.0+" = lgpl2Plus;
                      "lgpl-2.1" = lgpl21Only;
                      "lgpl-2.1-or-later" = lgpl21Plus;
                      "lgpl-3" = lgpl3Only;
                      "lgpl-3.0-or-later" = lgpl3Plus;
                      "lgplv3" = lgpl3Only;
                      "noassertion" = free;
                      "public-domain" = publicDomain;
                      "srfi" = bsd3;
                      "unicode" = ucd;
                      "xerox" = xerox;
                      "zlib-acknowledgement" = zlib;
                    })
                  ).${s} or s;
              in
              if builtins.isList license then map stringToLicense license else stringToLicense license;
          }
          // lib.optionalAttrs (homepage != null) {
            inherit homepage;
          }
          // lib.optionalAttrs (synopsis != null) {
            description = synopsis;
          };
        }).overrideAttrs
          ({ "${pname}" = lib.id; } // overrides)."${pname}";
      deps = lib.importTOML ./deps.toml;
      packages = lib.makeScope self.newScope (akkuself: lib.mapAttrs (makeAkkuPackage akkuself) deps);
    in
    lib.recurseIntoAttrs packages;
})
