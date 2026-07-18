{
  lib,
  fetchFromGitHub,
  aiofiles,
  async-timeout,
  buildPythonPackage,
  cryptography,
  isPy3k,
  libusb1,
  mock,
  pyasn1,
  pycryptodome,
  pytestCheckHook,
  pythonOlder,
  rsa,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "adb-shell";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "JeffLIrion";
    repo = "adb_shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-pOkFUh3SEu/ch9R1lVoQn50nufQp8oI+D4/+Ybal5CA=";
  };

  doCheck = pythonOlder "3.12"; # FIXME: tests are broken on 3.13

  nativeCheckInputs = [
    mock
    pycryptodome
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    cryptography
    pyasn1
    rsa
  ];

  disabled = !isPy3k;

  optional-dependencies = {
    async = [
      aiofiles
      async-timeout
    ];

    usb = [ libusb1 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "adb_shell" ];

  meta = {
    description = "Python implementation of ADB with shell and FileSync functionality";
    homepage = "https://github.com/JeffLIrion/adb_shell";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
})
