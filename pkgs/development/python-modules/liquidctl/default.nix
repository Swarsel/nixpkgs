{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorlog,
  crcmod,
  docopt,
  hidapi,
  i2c-tools,
  installShellFiles,
  pillow,
  pytestCheckHook,
  pyusb,
  setuptools,
  setuptools-scm,
  smbus-cffi,
  udevCheckHook,
  wheel,
}:

buildPythonPackage rec {
  pname = "liquidctl";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "liquidctl";
    repo = "liquidctl";
    tag = "v${version}";
    hash = "sha256-NN/LPcRwj1c9xIIBmNCSLkb+8LHPIqH/YuLPm3kxqEQ=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
    setuptools
    setuptools-scm
    wheel
    udevCheckHook
  ];

  propagatedBuildInputs = [
    docopt
    hidapi
    pyusb
    smbus-cffi
    i2c-tools
    colorlog
    crcmod
    pillow
  ];

  postBuild = ''
    # needed for pythonImportsCheck
    export XDG_RUNTIME_DIR=$TMPDIR
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    installManPage liquidctl.8
    installShellCompletion extra/completions/liquidctl.bash

    mkdir -p $out/lib/udev/rules.d
    cp extra/linux/71-liquidctl.rules $out/lib/udev/rules.d/.
  '';

  propagatedNativeBuildInputs = [ smbus-cffi ];
  pyproject = true;
  pythonImportsCheck = [ "liquidctl" ];

  meta = {
    description = "Cross-platform CLI and Python drivers for AIO liquid coolers and other devices";
    homepage = "https://github.com/liquidctl/liquidctl";
    changelog = "https://github.com/liquidctl/liquidctl/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      arturcygan
    ];

    mainProgram = "liquidctl";
  };
}
