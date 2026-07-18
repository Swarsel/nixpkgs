{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  looseversion,
  matplotlib,
  numba,
  numpy,
  pandas,
  pytestCheckHook,
  pyyaml,
  scipy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "trackpy";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "soft-matter";
    repo = "trackpy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3e+gHdn/4n8T78eA3Gjz1TdSI4Hd935U2pqd8wG+U0M=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # specifically needed for darwin
    export HOME=$(mktemp -d)
    mkdir -p $HOME/.matplotlib
    echo "backend: ps" > $HOME/.matplotlib/matplotlibrc
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    looseversion
    matplotlib
    numba
    numpy
    pandas
    pyyaml
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "trackpy" ];

  meta = {
    description = "Particle-tracking toolkit";
    homepage = "https://github.com/soft-matter/trackpy";
    changelog = "https://github.com/soft-matter/trackpy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    broken = (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
})
