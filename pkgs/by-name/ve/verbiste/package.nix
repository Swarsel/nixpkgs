{
  lib,
  stdenv,
  fetchurl,
  gtk2,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "verbiste";
  version = "0.1.49";

  src = fetchurl {
    url = "http://sarrazip.com/dev/verbiste-${finalAttrs.version}.tar.gz";
    hash = "sha256-SnVhM8DronsajiNtrlOuFzJWBbpIb+bLLrK+mWZoP6U=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gtk2
    libxml2
  ];

  enableParallelBuilding = true;

  meta = {
    description = "French and Italian verb conjugator";
    homepage = "http://sarrazip.com/dev/verbiste.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
