{
  lib,
  stdenv,
  fetchurl,
  netsurf-buildsystem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libutf8proc";
  version = "2.4.0-1";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/libutf8proc-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-AasdaYnBx3VQkNskw/ZOSflcVgrknCa+xRQrrGgCxHI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "UTF8 Processing library for netsurf browser";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.mit;
  };
})
