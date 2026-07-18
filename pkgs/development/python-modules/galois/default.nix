{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numba,
  numpy,
  pytest-xdist,
  pytestCheckHook,
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "galois";
  version = "0.4.11";

  src = fetchFromGitHub {
    owner = "mhostetter";
    repo = "galois";
    tag = "v${version}";
    hash = "sha256-iTxPsuWmaQ4L19ND0UeRLKrdM++M8UnT3I06z+E8jjc=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    numpy
    numba
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "galois" ];

  pythonRelaxDeps = [
    "numpy"
    "numba"
  ];

  meta = {
    description = "Python package that extends NumPy arrays to operate over finite fields";
    homepage = "https://github.com/mhostetter/galois";
    changelog = "https://github.com/mhostetter/galois/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chrispattison ];
    downloadPage = "https://github.com/mhostetter/galois/releases/tag/v${version}";
  };
}
