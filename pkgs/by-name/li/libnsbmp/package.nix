{
  lib,
  stdenv,
  fetchurl,
  netsurf-buildsystem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnsbmp";
  version = "0.1.7";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/libnsbmp-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-VAenaCoSK6qqWhW1BSkOLTffVME8Xt70sJ0SyGLYIpM=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "BMP Decoder for netsurf browser";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.mit;
  };
})
