{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nuclear,
  pydantic,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "wat";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "igrek51";
    repo = "wat";
    rev = version;
    hash = "sha256-ns5eF5jsmwCvx9jnTLG9w0ujH3cPAjzy9bRMgQHVKj4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    nuclear
    pydantic
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "wat" ];

  meta = {
    description = "Deep inspection of python objects";
    homepage = "https://igrek51.github.io/wat/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ parras ];
  };
}
