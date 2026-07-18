{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyprojectVersionPatchHook,
  pyserial-asyncio-fast,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  zigpy,
}:

buildPythonPackage rec {
  pname = "zigpy-xbee";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "zigpy";
    repo = "zigpy-xbee";
    tag = version;
    hash = "sha256-ALwhl9WUDkv0POufF/G/rZrn+ITbMdh6y86lShy6ZTg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools-git-versioning<2"' ""
  '';

  nativeBuildInputs = [
    pyprojectVersionPatchHook
  ];

  # lacking zigpy 2.0 compat
  # https://github.com/zigpy/zigpy-xbee/pull/179
  doCheck = false;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
    pyserial-asyncio-fast
  ];

  build-system = [ setuptools ];

  dependencies = [
    zigpy
  ];

  disabledTests = [
    "test_connect" # Attempts to test ioctl
  ];

  pyproject = true;

  meta = {
    description = "Library which communicates with XBee radios for zigpy";
    homepage = "https://github.com/zigpy/zigpy-xbee";
    changelog = "https://github.com/zigpy/zigpy-xbee/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mvnetbiz ];
    platforms = lib.platforms.linux;
  };
}
