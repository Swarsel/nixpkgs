{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  meson-python,
  ninja,

  # Reverse dependency
  sage,
}:

buildPythonPackage rec {
  pname = "cysignals";
  version = "1.12.6";

  src = fetchFromGitHub {
    owner = "sagemath";
    repo = "cysignals";
    tag = version;
    hash = "sha256-uZNKmnn1Jf1pERdG4bywpAUClKMw3og+7Q5B0yPlqEY=";
  };

  # known failure: https://github.com/sagemath/cysignals/blob/582dbf6a7b0f9ade0abe7a7b8720b7fb32435c3c/testgdb.py#L5
  doCheck = false;

  preCheck = ''
    # Make sure cysignals-CSI is in PATH
    export PATH="$out/bin:$PATH"
  '';

  build-system = [
    cython
    meson-python
    ninja
  ];

  checkTarget = "check-install";
  dontUseCmakeConfigure = true;
  enableParallelBuilding = true;
  # explicit check:
  # build/src/cysignals/implementation.c:27:2: error: #error "cysignals must be compiled without _FORTIFY_SOURCE"
  hardeningDisable = [ "fortify" ];
  pyproject = true;

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Interrupt and signal handling for Cython";
    homepage = "https://github.com/sagemath/cysignals/";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "cysignals-CSI";
    teams = [ lib.teams.sage ];
  };
}
