{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pysam,
  setuptools,
  unittestCheckHook,
  wheel,
}:

buildPythonPackage rec {
  pname = "pywfa";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "kcleal";
    repo = "pywfa";
    tag = "v${version}";
    hash = "sha256-TeJ7Jq4LR+I1+zeMeBtHZa9dR+CRJJG5sT99tB227P8=";
  };

  nativeBuildInputs = [
    cython
    setuptools
    wheel
  ];

  nativeCheckInputs = [
    pysam
    unittestCheckHook
  ];

  preCheck = ''
    cd pywfa/tests
  '';

  pyproject = true;

  pythonImportsCheck = [
    "pywfa"
    "pywfa.align"
  ];

  meta = {
    description = "Python wrapper for wavefront alignment using WFA2-lib";
    homepage = "https://github.com/kcleal/pywfa";
    changelog = "https://github.com/kcleal/pywfa/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
