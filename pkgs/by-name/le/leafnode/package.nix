{
  lib,
  stdenv,
  fetchurl,
  libxcrypt,
  pcre,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "leafnode";
  version = "2.0.0.alpha20140727b";

  src = fetchurl {
    url = "http://krusty.dt.e-technik.tu-dortmund.de/~ma/leafnode/beta/leafnode-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-NOuiy7uHG3JMjV3UAtHDWK6yG6QmvrVljhVe0NdGEHU=";
  };

  buildInputs = [
    pcre
    libxcrypt
  ];

  configureFlags = [ "--enable-runas-user=nobody" ];

  # configure uses id to check environment; we don't want this check
  preConfigure = ''
    sed -re 's/^ID[=].*/ID="echo whatever"/' -i configure
  '';

  # The is_validfqdn is far too restrictive, and only allows
  # Internet-facing servers to run.  In order to run leafnode via
  # localhost only, we need to disable this check.
  postConfigure = ''
    sed -i validatefqdn.c -e 's/int is_validfqdn(const char \*f) {/int is_validfqdn(const char *f) { return 1;/;'
  '';

  prePatch = ''
    substituteInPlace Makefile.in --replace 02770 0770
  '';

  meta = {
    description = "Implementation of a store & forward NNTP proxy, under development";
    homepage = "https://leafnode.sourceforge.io/index.shtml";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
