{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  # dependencies
  h5py,
  matplotlib,
  nanobind,
  ninja,
  numpy,
  pytestCheckHook,
  pyyaml,
  scikit-build-core,
  scipy,
  setuptools-scm,
  spglib,
  symfc,
}:

buildPythonPackage (finalAttrs: {
  pname = "phonopy";
  version = "3.5.1";

  src = fetchFromGitHub {
    owner = "phonopy";
    repo = "phonopy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P5anv0bg+L5dUdmZBECPNLa1AzjB782s8IfZCun7pN4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "nanobind<2.10.0" "nanobind"
  '';

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Prevents 'Fatal Python error: Aborted' on darwin during checkPhase
    MPLBACKEND = "Agg";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # prevent pytest from importing local directory
  preCheck = ''
    rm -r phonopy
  '';

  __structuredAttrs = true;

  build-system = [
    cmake
    nanobind
    ninja
    numpy
    scikit-build-core
    setuptools-scm
  ];

  dependencies = [
    h5py
    matplotlib
    numpy
    pyyaml
    scipy
    spglib
    symfc
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "phonopy" ];

  meta = {
    description = "Modulefor phonon calculations at harmonic and quasi-harmonic levels";
    homepage = "https://phonopy.github.io/phonopy/";
    changelog = "http://phonopy.github.io/phonopy/changelog.html";
    license = lib.licenses.bsd0;

    maintainers = with lib.maintainers; [
      psyanticy
      chn
    ];
  };
})
