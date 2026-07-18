{
  lib,
  stdenv,
  boehmgc,
  buildPackages,
  fetchFromSourcehut,
  gettext,
  gpm-ncurses,
  imlib2,
  libx11,
  man,
  ncurses,
  openssl,
  perl,
  pkg-config,
  testers,
  updateAutotoolsGnuConfigScriptsHook,
  w3m,
  zlib,
  graphicsSupport ? !stdenv.hostPlatform.isDarwin,
  mouseSupport ? !stdenv.hostPlatform.isDarwin,
  sslSupport ? true,
  x11Support ? graphicsSupport,
}:

let
  mktable = buildPackages.stdenv.mkDerivation {
    inherit (w3m) src;

    nativeBuildInputs = [
      pkg-config
      boehmgc
    ];

    makeFlags = [ "mktable" ];

    installPhase = ''
      install -D mktable $out/bin/mktable
    '';

    name = "w3m-mktable";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "w3m";
  version = "0.5.6";

  src = fetchFromSourcehut {
    owner = "~rkta";
    repo = "w3m";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VJztcvcmmA8f5RJ+NEYjPE8CGEfCRRjQ+fuF0UpY+sA=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    ./RAND_egd.libressl.patch
    ./https.patch
  ];

  postPatch = lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
    ln -s ${mktable}/bin/mktable mktable
    # stop make from recompiling mktable
    sed -i -e 's!mktable.*:.*!mktable:!' Makefile.in
  '';

  # updateAutotoolsGnuConfigScriptsHook necessary to build on FreeBSD native pending inclusion of
  # https://git.savannah.gnu.org/cgit/config.git/commit/?id=e4786449e1c26716e3f9ea182caf472e4dbc96e0
  nativeBuildInputs = [
    pkg-config
    gettext
    updateAutotoolsGnuConfigScriptsHook
  ];

  buildInputs = [
    ncurses
    boehmgc
    zlib
  ]
  ++ lib.optional sslSupport openssl
  ++ lib.optional mouseSupport gpm-ncurses
  ++ lib.optional graphicsSupport imlib2
  ++ lib.optional x11Support libx11;

  configureFlags = [
    "--with-ssl=${openssl.dev}"
    "--with-gc=${boehmgc.dev}"
    # The code won't compile in c23 mode.
    # https://gcc.gnu.org/gcc-15/porting_to.html#c23-fn-decls-without-parameters
    "CFLAGS=-std=gnu17"
  ]
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "ac_cv_func_setpgrp_void=${lib.boolToYesNo (!stdenv.hostPlatform.isBSD)}"
  ]
  ++ lib.optional graphicsSupport "--enable-image=${lib.optionalString x11Support "x11,"}fb"
  ++ lib.optional (graphicsSupport && !x11Support) "--without-x";

  makeFlags = [ "AR=${stdenv.cc.bintools.targetPrefix}ar" ];

  env = {
    # for w3mimgdisplay
    # see: https://bbs.archlinux.org/viewtopic.php?id=196093
    LIBS = lib.optionalString x11Support "-lX11";
    MAN = "${man}/bin/man";
    NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isSunOS "-lsocket -lnsl";
    # we must set these so that the generated files (e.g. w3mhelp.cgi) contain
    # the correct paths.
    PERL = "${perl}/bin/perl";
  };

  preConfigure = ''
    substituteInPlace ./configure --replace "/lib /usr/lib /usr/local/lib /usr/ucblib /usr/ccslib /usr/ccs/lib /lib64 /usr/lib64" /no-such-path
    substituteInPlace ./configure --replace /usr /no-such-path
  '';

  postInstall = lib.optionalString graphicsSupport ''
    ln -s $out/libexec/w3m/w3mimgdisplay $out/bin
  '';

  enableParallelBuilding = false;
  hardeningDisable = [ "format" ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "w3m -version";
    package = w3m;
  };

  meta = {
    description = "Text-mode web browser";
    homepage = "https://git.sr.ht/~rkta/w3m";
    changelog = "https://git.sr.ht/~rkta/w3m/tree/v${finalAttrs.version}/item/NEWS";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      anthonyroussel
      toastal
    ];

    platforms = lib.platforms.unix;
    mainProgram = "w3m";
  };
})
