{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  gmp,
  gnused,
  gpgme,
  installShellFiles,
  libedit,
  mpfr,
  nix-update-script,
  python3,
  texinfo,
  versionCheckHook,
  gpgmeSupport ? false,
  usePython ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ledger";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "ledger";
    repo = "ledger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yk6/4ImUzgZY8O7MmQMwFkuJ/pMXo6W5TAA0GGIxYgg=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals usePython [ "py" ];

  nativeBuildInputs = [
    cmake
    texinfo
    installShellFiles
  ];

  buildInputs = [
    gmp
    mpfr
    libedit
    gnused
  ]
  ++ lib.optionals gpgmeSupport [
    gpgme
  ]
  ++ (
    if usePython then
      [
        python3
        (boost.override {
          enablePython = true;
          python = python3;
        })
      ]
    else
      [ boost ]
  );

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeBool "BUILD_DOCS" true)
    (lib.cmakeBool "USE_PYTHON" usePython)
    (lib.cmakeBool "USE_GPGME" gpgmeSupport)
  ];

  postInstall = ''
    installShellCompletion --cmd ledger --bash $src/contrib/ledger-completion.bash
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  installTargets = [
    "doc"
    "install"
  ];

  # by default, it will query the python interpreter for it's sitepackages location
  # however, that would write to a different nixstore path, pass our own sitePackages location
  prePatch = lib.optionalString usePython ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail 'DESTINATION ''${Python_SITEARCH}' 'DESTINATION "${placeholder "py"}/${python3.sitePackages}"'
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Double-entry accounting system with a command-line reporting interface";

    longDescription = ''
      Ledger is a powerful, double-entry accounting system that is accessed
      from the UNIX command-line. This may put off some users, as there is
      no flashy UI, but for those who want unparalleled reporting access to
      their data, there really is no alternative.
    '';

    homepage = "https://www.ledger-cli.org/";
    changelog = "https://github.com/ledger/ledger/raw/v${finalAttrs.version}/NEWS.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      jwiegley
      afh
    ];

    platforms = lib.platforms.all;
    mainProgram = "ledger";
  };
})
