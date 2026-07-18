{
  lib,
  stdenv,
  fetchFromGitHub,
  libarchive,
  openssl,
  pkg-config,
  which,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xbps";
  version = "0.60.7";

  src = fetchFromGitHub {
    owner = "void-linux";
    repo = "xbps";
    tag = finalAttrs.version;
    hash = "sha256-noi+OAyBmLCBnmLDWEuNXEOPyqt9Qr1v4CNm7GjKXHA=";
  };

  patches = [
    ./cert-paths.patch
  ];

  # Don't try to install keys to /var/db/xbps, put in $out/share for now
  postPatch = ''
    substituteInPlace data/Makefile \
      --replace-fail '$(DESTDIR)/$(DBDIR)' '$(DESTDIR)/$(SHAREDIR)'
  '';

  nativeBuildInputs = [
    pkg-config
    which
  ];

  buildInputs = [
    zlib
    openssl
    libarchive
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=unused-result -Wno-error=deprecated-declarations";
  enableParallelBuilding = true;

  meta = {
    description = "X Binary Package System";
    homepage = "https://github.com/void-linux/xbps";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux; # known to not work on Darwin, at least
  };
})
