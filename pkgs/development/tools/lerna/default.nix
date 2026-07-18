{
  lib,
  callPackage,
}:

let
  inherit (lib) mapAttrs' nameValuePair;

  variants = {
    "6" = {
      version = "6.6.2";
      npmDepsHash = "sha256-yR3MUcmAVj0/+lLQk5+hmyGFnyqhzw1xjVsu7ciYccs=";
      hash = "sha256-B+o6SwVTrotHNYJW6CUXU/rJLK2VeGHvZYQZqbhYWjg=";
      packageLockFile = ./package-lock.v6.json;
    };

    "8" = {
      version = "8.1.9";
      npmDepsHash = "sha256-o3mLG0mBDIdkjusCKTSoradYlD8r4xdMyHH2HtOG9KQ=";
      hash = "sha256-Rs6utL5dsL2h+rpOwjbtwEyU5pRdaAWHexfOm18o6BA=";
      packageLockFile = ./package-lock.v8.json;
    };
  };

  callLerna =
    variant:
    callPackage ./generic.nix {
      inherit (variant)
        version
        hash
        npmDepsHash
        packageLockFile
        ;
    };

  mkLerna = versionSuffix: variant: nameValuePair "lerna_${versionSuffix}" (callLerna variant);
in
mapAttrs' mkLerna variants
