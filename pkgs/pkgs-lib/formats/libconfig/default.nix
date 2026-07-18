{
  lib,
  pkgs,
}:
let
  inherit (pkgs) buildPackages callPackage;

  libconfig-generator = buildPackages.rustPlatform.buildRustPackage {
    version = "0.1.0";
    src = ./src;
    cargoLock.lockFile = ./src/Cargo.lock;
    name = "libconfig-generator";
    passthru.updateScript = ./update.sh;
  };

  libconfig-validator =
    buildPackages.runCommandCC "libconfig-validator"
      {
        buildInputs = with buildPackages; [ libconfig ];
      }
      ''
        mkdir -p "$out/bin"
        $CC -lconfig -x c - -o "$out/bin/libconfig-validator" ${./validator.c}
      '';
in
{
  format =
    {
      generator ? libconfig-generator,
      validator ? libconfig-validator,
    }:
    {
      inherit generator;

      generate =
        name: value:
        callPackage
          (
            {
              libconfig-generator,
              libconfig-validator,
              stdenvNoCC,
              writeText,
            }:
            stdenvNoCC.mkDerivation rec {
              inherit name;
              strictDeps = true;
              nativeBuildInputs = [ libconfig-generator ];

              buildPhase = ''
                runHook preBuild
                libconfig-generator < $jsonPath > output.cfg
                runHook postBuild
              '';

              doCheck = true;
              nativeCheckInputs = [ libconfig-validator ];

              checkPhase = ''
                runHook preCheck
                libconfig-validator output.cfg
                runHook postCheck
              '';

              installPhase = ''
                runHook preInstall
                mv output.cfg $out
                runHook postInstall
              '';

              dontUnpack = true;
              json = builtins.toJSON value;
              passAsFile = [ "json" ];
              preferLocalBuild = true;
              passthru.json = writeText "${name}.json" json;
            }
          )
          {
            libconfig-generator = generator;
            libconfig-validator = validator;
          };

      lib = {
        mkArray = value: {
          inherit value;
          _type = "array";
        };

        mkFloat = value: {
          inherit value;
          _type = "float";
        };

        mkHex = value: {
          inherit value;
          _type = "hex";
        };

        mkList = value: {
          inherit value;
          _type = "list";
        };

        mkOctal = value: {
          inherit value;
          _type = "octal";
        };
      };

      type =
        with lib.types;
        let
          valueType =
            (oneOf [
              bool
              int
              float
              str
              path
              (attrsOf valueType)
              (listOf valueType)
            ])
            // {
              description = "libconfig value";
            };
        in
        attrsOf valueType;
    };
}
