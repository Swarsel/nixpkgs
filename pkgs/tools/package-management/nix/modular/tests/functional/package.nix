{
  lib,
  stdenv,
  git,
  jq,
  mercurial,
  meson,
  mkMesonDerivation,
  ninja,
  nix-cli,
  nix-expr,
  nix-store,
  pkg-config,
  util-linux,
  version,
  busybox-sandbox-shell ? null,
  # Configuration Options
  pname ? "nix-functional-tests",
  # For running the functional tests against a different pre-built Nix.
  test-daemon ? null,
}:

mkMesonDerivation (finalAttrs: {
  inherit pname version;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config

    jq
    git
    mercurial
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # For various sandboxing tests that needs a statically-linked shell,
    # etc.
    busybox-sandbox-shell
    # For Overlay FS tests need `mount`, `umount`, and `unshare`.
    # For `script` command (ensuring a TTY)
    # TODO use `unixtools` to be precise over which executables instead?
    util-linux
  ]
  ++ [
    nix-cli
  ];

  buildInputs = [
    nix-store
    nix-expr
  ];

  env = lib.optionalAttrs (test-daemon != null) {
    NIX_DAEMON_PACKAGE = test-daemon;
    _NIX_TEST_CLIENT_VERSION = nix-cli.version;
  };

  preConfigure =
    # TEMP hack for Meson before make is gone, where
    # `src/nix-functional-tests` is during the transition a symlink and
    # not the actual directory directory.
    ''
      cd $(readlink -e $PWD)
      echo $PWD | grep tests/functional
    '';

  doCheck = true;

  installPhase = ''
    mkdir $out
  '';

  mesonCheckFlags = [
    "--print-errorlogs"
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix;
  };

})
