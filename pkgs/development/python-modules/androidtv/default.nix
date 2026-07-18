{
  lib,
  fetchFromGitHub,
  adb-shell,
  aiofiles,
  async-timeout,
  buildPythonPackage,
  mock,
  pure-python-adb,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "androidtv";
  version = "0.0.75";

  src = fetchFromGitHub {
    owner = "JeffLIrion";
    repo = "python-androidtv";
    tag = "v${version}";
    hash = "sha256-2WFfGGEZkM3fWyTo5P6H3ha04Qyx2OiYetlGWv0jXac=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ optional-dependencies.async
  ++ optional-dependencies.usb;

  build-system = [ setuptools ];

  dependencies = [
    adb-shell
    async-timeout
    pure-python-adb
  ];

  disabledTests = [
    # Requires git but fails anyway
    "test_no_underscores"
  ];

  optional-dependencies = {
    inherit (adb-shell.optional-dependencies) usb;
    async = [ aiofiles ];
  };

  pyproject = true;
  pythonImportsCheck = [ "androidtv" ];

  meta = {
    description = "Communicate with an Android TV or Fire TV device via ADB over a network";
    homepage = "https://github.com/JeffLIrion/python-androidtv/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
