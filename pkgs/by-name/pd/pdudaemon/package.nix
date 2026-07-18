{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pdudaemon";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "pdudaemon";
    repo = "pdudaemon";
    tag = finalAttrs.version;
    hash = "sha256-YjM1RmsdRfNyxCzK+PmSH8n7ZJ3qeIskTPxu2+EaupQ=";
  };

  nativeCheckInputs = with python3Packages; [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with python3Packages; [
    aiohttp
    requests
    pexpect
    systemd-python
    paramiko
    pyserial
    hidapi
    pysnmp
    pyasn1
    pyusb
    pymodbus
  ];

  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) pdudaemon;
  };

  meta = {
    description = "Python Daemon for controlling/sequentially executing commands to PDUs (Power Distribution Units)";
    homepage = "https://github.com/pdudaemon/pdudaemon";
    changelog = "https://github.com/pdudaemon/pdudaemon/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      aiyion
      emantor
    ];

    mainProgram = "pdudaemon";
  };
})
