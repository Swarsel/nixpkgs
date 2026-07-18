{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  netsurf-buildsystem,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nsgenbind";
  version = "0.9";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/nsgenbind-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-Iyzg9my8LD7tYoiuJt4sVnu/u8Adiw9vxsHBZJ1LOF0=";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "Generator for JavaScript bindings for netsurf browser";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.mit;
    mainProgram = "nsgenbind";
  };
})
