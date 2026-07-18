{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  influxdb-client,
  pyserial,
  pytestCheckHook,
  pyusb,
  setuptools,
  udevCheckHook,
}:

buildPythonPackage rec {
  pname = "openant-unstable";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Tigge";
    repo = "openant";
    tag = "v${version}";
    hash = "sha256-wDtHlkVyD7mMDXZ4LGMgatr9sSlQKVbgkYsKvHGr9Pc=";
  };

  nativeBuildInputs = [
    setuptools
    udevCheckHook
  ];

  propagatedBuildInputs = [ pyusb ];
  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    install -dm755 "$out/etc/udev/rules.d"
    install -m644 resources/42-ant-usb-sticks.rules "$out/etc/udev/rules.d/99-ant-usb-sticks.rules"
  '';

  optional-dependencies = {
    influx = [ influxdb-client ];
    serial = [ pyserial ];
  };

  pyproject = true;
  pythonImportsCheck = [ "openant" ];

  meta = {
    description = "ANT and ANT-FS Python Library";
    homepage = "https://github.com/Tigge/openant";
    license = lib.licenses.mit;
    mainProgram = "openant";
  };
}
