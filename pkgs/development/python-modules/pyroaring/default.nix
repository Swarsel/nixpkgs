{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  hypothesis,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyroaring";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "Ezibenroc";
    repo = "PyRoaringBitMap";
    tag = version;
    hash = "sha256-7oHnYN44NVf2mjvHXaRgKtHFHMTQohpGEuQJjc9NGzw=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyroaring" ];

  meta = {
    description = "Python library for handling efficiently sorted integer sets";
    homepage = "https://github.com/Ezibenroc/PyRoaringBitMap";
    changelog = "https://github.com/Ezibenroc/PyRoaringBitMap/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
