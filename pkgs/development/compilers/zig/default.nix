{
  lib,
  callPackage,
  llvmPackages_18,
  llvmPackages_19,
  llvmPackages_20,
  llvmPackages_21,
  zigVersions ? { },
}:
let
  versions = {
    "0.13.0" = {
      hash = "sha256-5qSiTq+UWGOwjDVZMIrAt2cDKHkyNPBSAEjpRQUByFM=";
      llvmPackages = llvmPackages_18;
    };

    "0.14.1" = {
      hash = "sha256-DhVJIY/z12PJZdb5j4dnCRb7k1CmeQVOnayYRP8azDI=";
      llvmPackages = llvmPackages_19;
    };

    "0.15.2" = {
      hash = "sha256-u3pEMcYN71d83MJh14vtzU4DJXnMHu/Jw86d9XvwKE8=";
      llvmPackages = llvmPackages_20;
    };

    "0.16.0" = {
      hash = "sha256-2sTMhaasyrKoBnyH/hQrNCbi0Vh6HekIrpE4XkyQulQ=";
      llvmPackages = llvmPackages_21;
    };
  }
  // zigVersions;

  mkPackage =
    {
      hash,
      llvmPackages,
      version,
    }@args:
    callPackage ./generic.nix args;

  zigPackages = lib.mapAttrs' (
    version: args:
    lib.nameValuePair (lib.versions.majorMinor version) (mkPackage (args // { inherit version; }))
  ) versions;
in
zigPackages
