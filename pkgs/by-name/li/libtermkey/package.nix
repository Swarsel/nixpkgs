{
  lib,
  stdenv,
  fetchzip,
  libtool,
  ncurses,
  pkg-config,
  unibilium,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtermkey";
  version = "0.22";

  src = fetchzip {
    url = "https://www.leonerd.org.uk/code/libtermkey/libtermkey-${finalAttrs.version}.tar.gz";
    sha256 = "02dks6bj7n23lj005yq41azf95wh3hapmgc2lzyh12vigkjh67rg";
  };

  strictDeps = true;

  nativeBuildInputs = [
    libtool
    pkg-config
  ];

  buildInputs = [
    ncurses
    unibilium
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "LIBTOOL=${libtool}/bin/libtool"
  ];

  meta = {
    description = "Terminal keypress reading library";
    homepage = "http://www.leonerd.org.uk/code/libtermkey";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
