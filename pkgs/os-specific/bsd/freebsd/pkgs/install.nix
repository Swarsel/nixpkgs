{
  lib,
  stdenv,
  boot-install,
  bsdSetupHook,
  compatIfNeeded,
  freebsd-lib,
  freebsdSetupHook,
  groff,
  install,
  libmd,
  libnetbsd,
  makeMinimal,
  mandoc,
  mkDerivation,
  writeShellScript,
}:

# HACK: to ensure parent directories exist. This emulates GNU
# install’s -D option. No alternative seems to exist in BSD install.
let
  binstall = writeShellScript "binstall" (
    freebsd-lib.install-wrapper
    + ''

      @out@/bin/xinstall "''${args[@]}"
    ''
  );
  libmd' = libmd.override {
    bootstrapInstallation = true;
  };
in
mkDerivation {
  outputs = [
    "out"
    "man"
    "test"
  ];

  nativeBuildInputs = [
    bsdSetupHook
    freebsdSetupHook
    makeMinimal
    mandoc
    groff
    (if stdenv.hostPlatform == stdenv.buildPlatform then boot-install else install)
  ];

  buildInputs =
    compatIfNeeded
    ++ lib.optionals (!stdenv.hostPlatform.isFreeBSD) [
      libmd'
    ]
    ++ [
      libnetbsd
    ];

  makeFlags = [
    "STRIP=-s" # flag to install, not command
    "MK_WERROR=no"
    "TESTSDIR=${placeholder "test"}"
  ]
  ++ lib.optionals (stdenv.hostPlatform == stdenv.buildPlatform) [
    "BOOTSTRAPPING=1"
    "INSTALL=boot-install"
  ];

  postInstall = ''
    install -C -m 0550 ${binstall} $out/bin/binstall
    substituteInPlace $out/bin/binstall --subst-var out
    mv $out/bin/install $out/bin/xinstall
    ln -s ./binstall $out/bin/install
  '';

  extraPaths = [ "contrib/mtree" ];
  path = "usr.bin/xinstall";
  skipIncludesPhase = true;
}
