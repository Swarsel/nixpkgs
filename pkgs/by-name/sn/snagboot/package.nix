{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  python3Packages,
  snagboot,
  testers,
  udevCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "snagboot";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "bootlin";
    repo = "snagboot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZjN4k5prOoEdAT4z37XiHdnUgLsz3zeR3+0zxY+2420=";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    rules="src/snagrecover/50-snagboot.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi

    mkdir -p "$out/lib/udev/rules.d"
    cp "$rules" "$out/lib/udev/rules.d/50-snagboot.rules"
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pyyaml
    pyusb
    pyserial
    tftpy
    crccheck
    libfdt
    # swig
    packaging
    xmodem
  ];

  optional-dependencies = with python3Packages; {
    gui = [ kivy ];
  };

  pyproject = true;
  pythonRelaxDeps = [ "pylibfdt" ];

  pythonRemoveDeps = [
    "swig"
  ];

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "snagrecover --version";
      package = snagboot;
    };

    updateScript = gitUpdater {
      ignoredVersions = ".(rc|beta).*";
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Generic recovery and reflashing tool for embedded platforms";
    homepage = "https://github.com/bootlin/snagboot";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ otavio ];
  };
})
