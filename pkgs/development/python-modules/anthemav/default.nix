{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "anthemav";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "nugget";
    repo = "python-anthemav";
    tag = "v${version}";
    hash = "sha256-ZjAt4oODx09Qij0PwBvLCplSjwdBx2fReiwjmKhdPa0=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "anthemav" ];

  meta = {
    description = "Python asyncio module to interface with Anthem AVM and MRX receivers";
    homepage = "https://github.com/nugget/python-anthemav";
    changelog = "https://github.com/nugget/python-anthemav/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "anthemav_monitor";
  };
}
