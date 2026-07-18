{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "timelength";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "EtorixDev";
    repo = "timelength";
    tag = "v${version}";
    hash = "sha256-iaAtDkx6jPPB7s+sTQsrfNFiwerSDZ+7y7C9oNNYEmg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "timelength" ];

  meta = {
    description = "Flexible python duration parser designed for human readable lengths of time";
    homepage = "https://github.com/EtorixDev/timelength/";
    changelog = "https://github.com/EtorixDev/timelength/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vinetos ];
  };
}
