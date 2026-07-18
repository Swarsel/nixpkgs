{
  lib,
  stdenv,
  buildPythonPackage,
  # build-system
  cmake,
  ninja,
  # dependencies
  numpy,
  # nativeBuildInputs
  openmpi,
  pip,
  pkgs,
  setuptools,
  mpiSupport ? false,
}:
let
  conduit = pkgs.conduit.override { inherit mpiSupport; };
in
buildPythonPackage {
  inherit (conduit)
    pname
    version
    src
    # nativeBuildInputs
    buildInputs
    ;

  postPatch = (conduit.postPatch or "") + ''
    substituteInPlace pyproject.toml \
      --replace-fail \
        "cmake<=3.30.0" \
        "cmake"
  '';

  nativeBuildInputs = conduit.nativeBuildInputs ++ [
    # openmpi needs to be in nativeBuildInputs, otherwise cmake can't find it
    openmpi
  ];

  env.ENABLE_MPI = mpiSupport;
  # No python tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    cmake
    ninja
    pip
    setuptools
  ];

  dependencies = [
    numpy
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "conduit" ];

  meta = {
    inherit (conduit.meta)
      homepage
      changelog
      license
      platforms
      ;

    description = "Python bindings for the conduit library";
    maintainers = with lib.maintainers; [ GaetanLepage ];
    # Cross-compilation is broken
    broken = stdenv.hostPlatform != stdenv.buildPlatform;
  };
}
