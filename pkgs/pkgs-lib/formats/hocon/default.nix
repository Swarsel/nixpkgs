{
  lib,
  pkgs,
}:
let
  inherit (pkgs) buildPackages callPackage;

  hocon-generator = buildPackages.rustPlatform.buildRustPackage {
    version = "0.1.0";
    src = ./src;
    cargoLock.lockFile = ./src/Cargo.lock;
    name = "hocon-generator";
    passthru.updateScript = ./update.sh;
  };

  hocon-validator =
    pkgs.writers.writePython3Bin "hocon-validator"
      {
        libraries = [ pkgs.python3Packages.pyhocon ];
      }
      ''
        from sys import argv
        from pyhocon import ConfigFactory

        if not len(argv) == 2:
            print("USAGE: hocon-validator <file>")

        ConfigFactory.parse_file(argv[1])
      '';
in
{
  format =
    {
      doCheck ? true,
      generator ? hocon-generator,
      validator ? hocon-validator,
    }:
    let
      hoconLib = {
        mkAppend = value: {
          inherit value;
          _type = "append";
        };

        mkInclude =
          value:
          let
            includeStatement =
              if lib.isAttrs value && !(lib.isDerivation value) then
                {
                  _type = "include";
                  required = false;
                  type = null;
                }
                // value
              else
                {
                  _type = "include";
                  required = false;
                  type = null;
                  value = toString value;
                };
          in
          assert lib.assertMsg
            (lib.elem includeStatement.type [
              "file"
              "url"
              "classpath"
              null
            ])
            ''
              Type of HOCON mkInclude is not of type 'file', 'url' or 'classpath':
              ${(lib.generators.toPretty { }) includeStatement}
            '';
          includeStatement;

        mkSubstitution =
          value:
          if lib.isString value then
            {
              inherit value;
              _type = "substitution";
              optional = false;
            }
          else
            assert lib.assertMsg (lib.isAttrs value) ''
              Value of invalid type provided to `hocon.lib.mkSubstitution`: ${lib.typeOf value}
            '';
            assert lib.assertMsg (value ? "value") ''
              Argument to `hocon.lib.mkSubstitution` is missing a `value`:
              ${builtins.toJSON value}
            '';
            {
              _type = "substitution";
              optional = value.optional or false;
              value = value.value;
            };
      };

    in
    {
      generate =
        name: value:
        callPackage
          (
            {
              hocon-generator,
              hocon-validator,
              stdenvNoCC,
              writeText,
            }:
            stdenvNoCC.mkDerivation rec {
              inherit name;
              inherit doCheck;
              strictDeps = true;
              nativeBuildInputs = [ hocon-generator ];

              buildPhase = ''
                runHook preBuild
                hocon-generator < $jsonPath > output.conf
                runHook postBuild
              '';

              nativeCheckInputs = [ hocon-validator ];

              checkPhase = ''
                runHook preCheck
                hocon-validator output.conf
                runHook postCheck
              '';

              installPhase = ''
                runHook preInstall
                mv output.conf $out
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
            hocon-generator = generator;
            hocon-validator = validator;
          };

      lib = hoconLib;

      type =
        let
          type' =
            with lib.types;
            let
              atomType = nullOr (oneOf [
                bool
                float
                int
                path
                str
              ]);

              includeType = addCheck attrs (x: (x._type or null) == "include");
            in
            (oneOf [
              atomType
              (addCheck (listOf atomType) (lib.all atomType.check))
              (addCheck (listOf includeType) (lib.all includeType.check))
              (attrsOf type')
            ])
            // {
              description = "HOCON value";
            };
        in
        type';
    };
}
