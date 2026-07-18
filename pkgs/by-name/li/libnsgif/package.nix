{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  netsurf-buildsystem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnsgif";
  version = "1.0.0";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/libnsgif-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-YBTIQvYUVNL1oPgkPXqNe96bfaPM/cotNGx8CyxMBhs=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
    "BUILD_CC=$(CC_FOR_BUILD)"
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "GIF Decoder for netsurf browser";
    homepage = "https://www.netsurf-browser.org/projects/libnsgif/";
    license = lib.licenses.mit;
  };
})
