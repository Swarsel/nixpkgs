{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "re-assert";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "asottile";
    repo = "re-assert";
    tag = "v${version}";
    hash = "sha256-UTXFTD3QOKIzjq05J9Ontv5h9aClOwlPYKFXfDnBWuc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ regex ];
  pyproject = true;
  pythonImportsCheck = [ "re_assert" ];

  meta = {
    description = "Show where your regex match assertion failed";
    homepage = "https://github.com/asottile/re-assert";
    license = lib.licenses.mit;
  };
}
