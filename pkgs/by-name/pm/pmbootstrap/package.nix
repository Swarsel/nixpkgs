{
  lib,
  stdenv,
  fetchFromGitLab,
  git,
  gitUpdater,
  multipath-tools,
  openssl,
  ps,
  python3Packages,
  sudo,
  util-linux,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "pmbootstrap";
  version = "3.10.3";

  src = fetchFromGitLab {
    owner = "postmarketOS";
    repo = "pmbootstrap";
    tag = version;
    hash = "sha256-Zl7Ti0HwMQSjMeW4GjdEKIRoCNjV15Qiv8bzhktNoyQ=";
    domain = "gitlab.postmarketos.org";
  };

  # Tests depend on sudo
  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    git
    multipath-tools
    openssl
    ps
    python3Packages.pytestCheckHook
    sudo
    util-linux
    versionCheckHook
  ];

  # Add test dependency in PATH
  preCheck = ''
    export PYTHONPATH=$PYTHONPATH:${pmb_test}
  '';

  build-system = [
    python3Packages.setuptools
  ];

  # skip impure tests
  disabledTests = [
    "test_pkgrepo_pmaports"
    "test_random_valid_deviceinfos"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # assert chroot.type == ChrootType.BUILDROOT
    # AssertionError: assert <ChrootType.NATIVE: 'native'> == <ChrootType.BUILDROOT: 'buildroot'>
    "test_valid_chroots"
  ];

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        git
        openssl
        multipath-tools
        util-linux
      ]
    }"
  ];

  pmb_test = "${src}/test";
  pyproject = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Sophisticated chroot/build/flash tool to develop and install postmarketOS";
    homepage = "https://gitlab.postmarketos.org/postmarketOS/pmbootstrap";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      onny
      ungeskriptet
    ];

    mainProgram = "pmbootstrap";
  };
}
