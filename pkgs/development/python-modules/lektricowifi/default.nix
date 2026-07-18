{
  lib,
  fetchFromGitHub,
  async-timeout,
  buildPythonPackage,
  httpx,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lektricowifi";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "Lektrico";
    repo = "lektricowifi";
    tag = "v.${version}";
    hash = "sha256-GkRZ+fBjLtiZ3dPsn/xeJ7c0cVMY6SHIs+wqhmXXOTk=";
  };

  # AttributeError: type object 'InfoForCharger' has no attribute 'from_dict'
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    async-timeout
    httpx
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "lektricowifi" ];

  pythonRelaxDeps = [
    "pydantic"
  ];

  meta = {
    description = "Communication with Lektrico's chargers";
    homepage = "https://github.com/Lektrico/lektricowifi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
