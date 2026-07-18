{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libow";
  version = "3.2p4";

  src = fetchFromGitHub {
    owner = "owfs";
    repo = "owfs";
    rev = "v${finalAttrs.version}";
    sha256 = "0dln1ar7bxwhpi36sccmpwapy7iz4j097rbf02mgn42lw5vrcg3s";
  };

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
  ];

  configureFlags = [
    "--disable-owtcl"
    "--disable-owphp"
    "--disable-owpython"
    "--disable-zero"
    "--disable-owshell"
    "--disable-owhttpd"
    "--disable-owftpd"
    "--disable-owserver"
    "--disable-owperl"
    "--disable-owtap"
    "--disable-owmon"
    "--disable-owexternal"
  ];

  preConfigure = ''
    # Tries to use glibtoolize on Darwin, but it shouldn't for Nix.
    sed -i -e 's/glibtoolize/libtoolize/g' bootstrap
    ./bootstrap
  '';

  meta = {
    description = "1-Wire File System full library";
    homepage = "https://owfs.org/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ disserman ];
    platforms = lib.platforms.unix;
  };
})
