{
  lib,
  stdenv,
  fetchurl,
  gettext,
  libextractor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "doodle";
  version = "0.7.3";

  src = fetchurl {
    url = "https://grothoff.org/christian/doodle/download/doodle-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-qodp2epYyolg38MNhBV+/NMLmfXjhsn2X9uKTUniv2s=";
  };

  buildInputs = [
    libextractor
    gettext
  ];

  meta = {
    description = "Tool to quickly index and search documents on a computer";
    homepage = "https://grothoff.org/christian/doodle/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; linux;
    mainProgram = "doodle";
  };
})
