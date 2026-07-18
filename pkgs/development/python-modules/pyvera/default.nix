{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "pyvera";
  version = "0.3.16";

  src = fetchFromGitHub {
    owner = "pavoni";
    repo = "pyvera";
    tag = version;
    hash = "sha256-WLzVOQEykST2BsVRHmcBhrsd/am0jI/f7D0PmpCTbdQ=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytest-cov-stub
    pytestCheckHook
    responses
  ];

  build-system = [ poetry-core ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pyvera" ];

  meta = {
    description = "Python library to control devices via the Vera hub";
    homepage = "https://github.com/pavoni/pyvera";
    changelog = "https://github.com/maximvelichko/pyvera/releases/tag/${version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
