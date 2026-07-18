{
  lib,
  stdenv,
  fetchFromGitHub,
  libpcap,
  ppp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xl2tpd";
  version = "1.3.20";

  src = fetchFromGitHub {
    owner = "xelerance";
    repo = "xl2tpd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-T4oEMMLb/SPkXfJ55fxBx9ii98qZVZRxPoU/eXlKb4U=";
  };

  postPatch = ''
    substituteInPlace l2tp.h --replace /usr/sbin/pppd ${ppp}/sbin/pppd
  '';

  buildInputs = [ libpcap ];
  makeFlags = [ "PREFIX=$(out)" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types -std=gnu17";

  meta = {
    description = "Layer 2 Tunnelling Protocol Daemon (RFC 2661)";
    homepage = finalAttrs.src.meta.homepage;
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
