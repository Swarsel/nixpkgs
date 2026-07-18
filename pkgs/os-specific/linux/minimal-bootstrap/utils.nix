{
  lib,
  buildPlatform,
  callPackage,
  checkMeta,
  config,
  hostPlatform,
  kaem,
  mescc-tools-extra,
}:
let
  assertValidity = checkMeta.assertValidity hostPlatform;
  commonMeta = checkMeta.commonMeta hostPlatform;
in
rec {
  derivationWithMeta =
    attrs:
    let
      passthru = attrs.passthru or { };
      validity = assertValidity { inherit meta attrs; };
      meta = commonMeta { inherit validity attrs; };
      baseDrv = derivation (
        {
          inherit (buildPlatform) system;
          # redefining from meta to avoid forcing the thunk until it's used
          name = attrs.name or "${attrs.pname}-${attrs.version}";
        }
        // maybeContentAddressed
        // (removeAttrs attrs [
          "meta"
          "passthru"
        ])
      );
      passthru' =
        passthru
        // lib.optionalAttrs (passthru ? tests) {
          tests = lib.mapAttrs (_: f: f baseDrv) passthru.tests;
        };
    in
    lib.extendDerivation validity.handled (
      {
        inherit meta;
        passthru = passthru';
      }
      // passthru'
    ) baseDrv;

  maybeContentAddressed = lib.optionalAttrs config.contentAddressedByDefault {
    __contentAddressed = true;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  writeText = name: text: writeTextFile { inherit name text; };

  writeTextFile =
    {
      name, # the name of the derivation
      text,
      destination ? "", # relative path appended to $out eg "/bin/foo"
      executable ? false, # run chmod +x ?
    }:
    derivationWithMeta {
      inherit name text;
      inherit destination;
      PATH = lib.makeBinPath [ mescc-tools-extra ];

      args = [
        "--verbose"
        "--strict"
        "--file"
        (builtins.toFile "write-text-file.kaem" (
          ''
            target=''${out}''${destination}
          ''
          + lib.optionalString (dirOf destination == ".") ''
            mkdir -p ''${out}''${destinationDir}
          ''
          + ''
            cp ''${textPath} ''${target}
          ''
          + lib.optionalString executable ''
            chmod 555 ''${target}
          ''
        ))
      ];

      builder = "${kaem}/bin/kaem";
      destinationDir = dirOf destination;
      passAsFile = [ "text" ];
    };

}
