{
  lib,
  stdenv,
  clr,
  emptyDirectory,
  linkFarm,
  magma-hip,
  ollama,
  python3Packages,
  rocmPackages,
}:
# This package exists purely to have a bunch of passthru.tests attrs
let
  availableRocmDrvs = lib.pipe rocmPackages [
    (lib.mapAttrsToList (
      name: value: {
        inherit name;
        evaluated = builtins.tryEval value;
      }
    ))
    (builtins.filter (x: x.evaluated.success))
    (map (x: {
      inherit (x) name;
      value = x.evaluated.value;
    }))
    (builtins.filter (x: lib.isDerivation x.value && (x.value.meta.available or true)))
  ];
in
stdenv.mkDerivation {
  src = emptyDirectory;

  nativeBuildInputs = [
    clr
  ];

  postInstall = "mkdir -p $out";
  name = "rocm-tests";

  passthru.tests = {
    ollama = ollama.override {
      inherit rocmPackages;
      acceleration = "rocm";
    };

    rocmPackagesDerivations = linkFarm "rocmPackagesDerivations" (
      map (x: {
        name = x.name;
        path = x.value;
      }) availableRocmDrvs
    );

    torch = python3Packages.torch.override {
      inherit rocmPackages;
      cudaSupport = false;

      magma-hip = magma-hip.override {
        inherit rocmPackages;
      };

      rocmSupport = true;
    };
  };
}
