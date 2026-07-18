{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "wsdot";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "ucodery";
    repo = "wsdot";
    tag = "v${version}";
    hash = "sha256-ZmQXa/C5AxqzAdmxqStWnCLrm3AJb/krxbDhtLYMWPw=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    pydantic
  ];

  pyproject = true;
  pythonImportsCheck = [ "wsdot" ];

  meta = {
    description = "Python wrapper of the wsdot.wa.gov APIs";
    homepage = "https://github.com/ucodery/wsdot";
    changelog = "https://github.com/ucodery/wsdot/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
