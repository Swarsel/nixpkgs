{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pyftdi,
  pyopenssl,
  pyserial,
  pytestCheckHook,
  pyusb,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "alarmdecoder";
  version = "1.13.14";

  src = fetchFromGitHub {
    owner = "nutechsoftware";
    repo = "alarmdecoder";
    rev = version;
    hash = "sha256-qjn6OY8N1Miuou2aCHGhAQJtOEH1kE6XM8k1TPAibGU=";
  };

  postPatch = ''
    substituteInPlace test/test_{ad2,devices,messages}.py \
      --replace-fail assertEquals assertEqual
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    pyftdi
    pyopenssl
    pyserial
    pyusb
  ];

  disabledTests = [
    # Socket issue, https://github.com/nutechsoftware/alarmdecoder/issues/45
    "test_ssl"
    "test_ssl_exception"
  ];

  pyproject = true;
  pythonImportsCheck = [ "alarmdecoder" ];

  meta = {
    description = "Python interface for the Alarm Decoder (AD2USB, AD2SERIAL and AD2PI) devices";
    homepage = "https://github.com/nutechsoftware/alarmdecoder";
    changelog = "https://github.com/nutechsoftware/alarmdecoder/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
