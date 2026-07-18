{
  lib,
  fetchFromGitHub,
  base58,
  buildPythonPackage,
  coincurve,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "bip32";
  version = "5.0";

  # the PyPi source distribution ships a broken setup.py, so use github instead
  src = fetchFromGitHub {
    owner = "darosior";
    repo = "python-bip32";
    rev = version;
    hash = "sha256-QO1gS9bx/eQPaLuB1ZNZuXj4DmeO4/La2hG9NCXjd+4=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    base58
    coincurve
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "bip32" ];
  pythonRelaxDeps = [ "coincurve" ];

  meta = {
    description = "Minimalistic implementation of the BIP32 key derivation scheme";
    homepage = "https://github.com/darosior/python-bip32";
    changelog = "https://github.com/darosior/python-bip32/blob/${version}/CHANGELOG.md";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ arcnmx ];
  };
}
