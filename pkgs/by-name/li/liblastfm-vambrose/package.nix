{
  lib,
  stdenv,
  fetchurl,
  curl,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liblastfm-vambrose";
  version = "0.5";

  src = fetchurl {
    url = "mirror://sourceforge/liblastfm/libclastfm-${finalAttrs.version}.tar.gz";
    sha256 = "0hpfflvfx6r4vvsbvdc564gkby8kr07p8ma7hgpxiy2pnlbpian9";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    curl
    openssl
  ];

  meta = {
    description = "Unofficial C lastfm library";
    homepage = "https://liblastfm.sourceforge.net";
    license = lib.licenses.gpl3;
  };
})
