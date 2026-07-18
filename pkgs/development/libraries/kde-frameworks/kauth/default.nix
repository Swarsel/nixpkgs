{
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  kcoreaddons,
  mkDerivation,
  polkit-qt,
  propagate,
  qttools,
  enablePolkit ? stdenv.hostPlatform.isLinux,
}:

mkDerivation {
  pname = "kauth";

  # library stores reference to plugin path,
  # separating $out from $bin would create a reference cycle
  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./cmake-install-paths.patch
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = lib.optional enablePolkit polkit-qt ++ [ qttools ];
  propagatedBuildInputs = [ kcoreaddons ];
  setupHook = propagate "out";
}
