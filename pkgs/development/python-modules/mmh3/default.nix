{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mmh3";
  version = "5.2.1";

  src = fetchFromGitHub {
    owner = "hajimes";
    repo = "mmh3";
    tag = "v${version}";
    hash = "sha256-5a9r2nEuMeVPAEPy7NkG/RNeSsKtKSy2IjEbhBWTaDc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "mmh3" ];

  meta = {
    description = "Python wrapper for MurmurHash3, a set of fast and robust hash functions";
    homepage = "https://github.com/hajimes/mmh3";
    changelog = "https://github.com/hajimes/mmh3/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.cc0;
    maintainers = [ lib.maintainers.sarahec ];
  };
}
