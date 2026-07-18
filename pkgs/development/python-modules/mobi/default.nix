{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  loguru,
  pytestCheckHook,
  pythonOlder,
  standard-imghdr,
}:

buildPythonPackage rec {
  pname = "mobi";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "iscc";
    repo = "mobi";
    tag = "v${version}";
    hash = "sha256-Hbw4TX/yKkuxYQ9vZZp/wasDCop8pvyQc5zWloMQbng=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  dependencies = [
    loguru
    standard-imghdr
  ];

  pyproject = true;
  pythonImportsCheck = [ "mobi" ];
  pythonRelaxDeps = [ "loguru" ];
  pythonRemoveDeps = lib.optionals (pythonOlder "3.13") [ "standard-imghdr" ];

  meta = {
    description = "Library for unpacking unencrypted mobi files";
    homepage = "https://github.com/iscc/mobi";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "mobiunpack";
  };
}
