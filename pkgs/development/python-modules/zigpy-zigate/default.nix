{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gpiozero,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  pyusb,
  setuptools,
  voluptuous,
  zigpy,
}:

buildPythonPackage rec {
  pname = "zigpy-zigate";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "zigpy";
    repo = "zigpy-zigate";
    tag = version;
    hash = "sha256-kimlUwwlecXIBxKkBUJC8JqzMdt6Swf5SuOypOnXZCM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    gpiozero
    pyusb
    voluptuous
    zigpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "zigpy_zigate" ];

  meta = {
    description = "Library which communicates with ZiGate radios for zigpy";
    homepage = "https://github.com/zigpy/zigpy-zigate";
    changelog = "https://github.com/zigpy/zigpy-zigate/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mvnetbiz ];
    platforms = lib.platforms.linux;
  };
}
