{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cabextract";
  version = "1.11";

  src = fetchurl {
    url = "https://www.cabextract.org.uk/cabextract-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-tVRtsRVeTHGP89SyeFc2BPMN1kw8W/1GV80Im4I6OsY=";
  };

  # Remove vendored getopt.h in favor of stdenv's to fix non-gnu builds.
  postPatch = ''
    rm getopt.h
  '';

  # Let's assume that fnmatch works for cross-compilation, otherwise it gives an error:
  # undefined reference to `rpl_fnmatch'.
  configureFlags = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    "ac_cv_func_fnmatch_works=yes"
  ];

  meta = {
    description = "Free Software for extracting Microsoft cabinet files";
    homepage = "https://www.cabextract.org.uk/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.all;
    mainProgram = "cabextract";
  };
})
