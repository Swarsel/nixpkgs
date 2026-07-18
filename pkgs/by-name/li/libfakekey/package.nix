{
  lib,
  stdenv,
  autoconf,
  automake,
  fetchgit,
  libtool,
  libx11,
  libxi,
  libxtst,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libfakekey";
  version = "0.3";

  src = fetchgit {
    url = "https://git.yoctoproject.org/libfakekey";
    tag = finalAttrs.version;
    hash = "sha256-QNJlxZ9uNwNgFWm9qRJdPfusx7dXHZajjFH7wDhpgcs=";
  };

  nativeBuildInputs = [
    automake
    autoconf
    pkg-config
    libtool
  ];

  buildInputs = [
    libx11
    libxi
    libxtst
    xorgproto
  ];

  env.NIX_LDFLAGS = "-lX11";
  configureScript = "./autogen.sh";

  meta = {
    description = "X virtual keyboard library";
    homepage = "https://www.yoctoproject.org/tools-resources/projects/matchbox";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
