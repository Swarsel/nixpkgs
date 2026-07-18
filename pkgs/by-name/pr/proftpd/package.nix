{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libcap,
  libsodium,
  libxcrypt-legacy,
  ncurses,
  openssl,
  perl,
  removeReferencesTo,
  zlib,
}:

let
  perl' = perl.override {
    libxcrypt = libxcrypt-legacy;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "proftpd";
  version = "1.3.9a";

  src = fetchFromGitHub {
    owner = "proftpd";
    repo = "proftpd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SNLzIwMF6XU2SAc5B9LIW2Jeh1Fa4CVumQYd2O0XxRY=";
  };

  outputs = [
    "out"
    "man"
    "dev"
  ];

  patches = [
    ./no-install-user.patch
    (fetchpatch {
      hash = "sha256-1YM9yeiZJwU2CasPhf4g9O8Jf/B01ullFeUkERFe9WY=";
      name = "CVE-2026-44331.patch";
      url = "https://github.com/proftpd/proftpd/commit/5e06acc4687046c7bf794b55bd8c44a86a05ae61.patch";
    })
  ];

  strictDeps = true;
  nativeBuildInputs = [ removeReferencesTo ];

  buildInputs = [
    libcap
    libsodium
    openssl
    zlib
    perl'
    ncurses
  ];

  configureFlags = [
    "--enable-openssl"
    "--with-modules=mod_sftp"
  ];

  postInstall = ''
    patchShebangs $out/bin

    # This causes a cyclic dependency between $out and $dev, but for
    # no good reason: `--enable-dso` is disabled, so this isn't functional
    # and even then we'd need special support for building custom proftpd
    # modules since installing stuff into the store later on
    # doesn't work anyways.
    rm $out/bin/prxs

    # Remove unneeded directories:
    # * var doesn't make sense in the store
    # * share/locale is not used
    # * libexec seems to be needed for custom modules
    #   only which is not supported by this package.
    rm -r $out/{var,share,libexec}
  '';

  postFixup = ''
    # Strip away configure flags from proftpd that point to $dev.
    remove-references-to -t $dev $out/bin/*
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Highly configurable GPL-licensed FTP server software";
    homepage = "http://www.proftpd.org/";
    changelog = "http://proftpd.org/docs/RELEASE_NOTES-${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = [
      lib.maintainers.leona
      lib.maintainers.osnyx
    ];

    platforms = lib.platforms.unix;
    mainProgram = "proftpd";
  };
})
