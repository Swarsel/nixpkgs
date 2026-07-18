{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  installShellFiles,
  procps,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "yubikey-manager";
  version = "5.9.2";

  src = fetchFromGitHub {
    owner = "Yubico";
    repo = "yubikey-manager";
    tag = version;
    hash = "sha256-9ngsjXkQ3YUc5nCgG1i592LoVERr4jRSKi8POBaP/aw=";
  };

  postPatch = ''
    substituteInPlace "ykman/pcsc/__init__.py" \
      --replace-fail 'pkill' '${if stdenv.hostPlatform.isLinux then procps else "/usr"}/bin/pkill'
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  nativeCheckInputs = with python3Packages; [
    astroid
    makefun
    pytestCheckHook
  ];

  postInstall = ''
    installManPage man/ykman.1
  ''
  + (
    let
      compOpts =
        x:
        if stdenv.buildPlatform.canExecute python3Packages.stdenv.hostPlatform then
          "--${x} <(_YKMAN_COMPLETE=${x}_source ${placeholder "out"}/bin/ykman)"
        else
          ''--${x} <(_YKMAN_COMPLETE=${x}_source PYTHONPATH= "${buildPackages.yubikey-manager}/bin/ykman")'';
    in
    ''
      installShellCompletion --cmd ykman ${
        lib.strings.concatMapStringsSep " " compOpts [
          "bash"
          "zsh"
          "fish"
        ]
      }
    ''
  );

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    click
    cryptography
    fido2
    keyring
    pyscard
    python-pskc
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "cryptography"
  ];

  meta = {
    description = "Command line tool for configuring any YubiKey over all USB transports";
    homepage = "https://developers.yubico.com/yubikey-manager";
    changelog = "https://github.com/Yubico/yubikey-manager/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      benley
      lassulus
      pinpox
      nickcao
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ykman";
  };
}
