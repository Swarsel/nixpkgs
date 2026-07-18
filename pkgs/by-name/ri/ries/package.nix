{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ries";
  version = "2018.04.11-1";

  # upstream does not provide a stable link
  src = fetchzip {
    url = "https://salsa.debian.org/debian/ries/-/archive/debian/${finalAttrs.version}/ries-debian-${finalAttrs.version}.zip";
    sha256 = "1h2wvd4k7f0l0i1vm9niz453xdbcs3nxccmri50qyrzzzc1b0842";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Tool to produce a list of equations that approximately solve to a given number";
    homepage = "https://mrob.com/pub/ries/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ symphorien ];
    platforms = lib.platforms.all;
    mainProgram = "ries";
  };
})
