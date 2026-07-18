{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  netsurf-buildsystem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnslog";
  version = "0.1.3";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/libnslog-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-/JjcqdfvpnCWRwpdlsAjFG4lv97AjA23RmHHtNsEU9A=";
  };

  nativeBuildInputs = [
    bison
    flex
    pkg-config
  ];

  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "NetSurf Parametric Logging Library";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.isc;
  };
})
