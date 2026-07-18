{
  lib,
  stdenv,
  fetchFromGitHub,
  attr,
  autoconf,
  automake,
  gettext,
  libiconv,
  libtool,
  pandoc,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mergerfs";
  version = "2.42.0";

  src = fetchFromGitHub {
    owner = "trapexit";
    repo = "mergerfs";
    rev = finalAttrs.version;
    sha256 = "sha256-FTkJpZkrU9ALMnmeqh1w9r46x4Waq30lA8yAHg3Y54s=";
  };

  nativeBuildInputs = [
    automake
    autoconf
    pkg-config
    gettext
    libtool
    pandoc
    which
  ];

  buildInputs = [
    attr
    libiconv
  ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
    "XATTR_AVAILABLE=1"
    "PREFIX=/"
    "SBINDIR=/bin"
    "CHMOD=true"
    "CHOWN=true"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=unused-result"
    "-Wno-error=maybe-uninitialized"

    # NOTE: _FORTIFY_SOURCE requires compiling with optimization (-O)
    "-O"
  ];

  preConfigure = ''
    echo "${finalAttrs.version}" > VERSION
  '';

  postFixup = ''
    ln -srf $out/bin/mergerfs $out/bin/mount.fuse.mergerfs
    ln -srf $out/bin/mergerfs $out/bin/mount.mergerfs
  '';

  enableParallelBuilding = true;

  meta = {
    description = "FUSE based union filesystem";
    homepage = "https://github.com/trapexit/mergerfs";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ makefu ];
    platforms = lib.platforms.linux;
  };
})
