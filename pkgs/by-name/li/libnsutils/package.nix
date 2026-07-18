{
  lib,
  stdenv,
  fetchurl,
  netsurf-buildsystem,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libnsutils";
  version = "0.1.1";

  src = fetchurl {
    url = "https://download.netsurf-browser.org/libs/releases/libnsutils-${finalAttrs.version}-src.tar.gz";
    hash = "sha256-VpS0Um5FjtAAQTzmAnWJy+EKJXp+zwZaAUIdxymd6pI=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ netsurf-buildsystem ];

  makeFlags = [
    "PREFIX=$(out)"
    "NSSHARED=${netsurf-buildsystem}/share/netsurf-buildsystem"
  ];

  meta = {
    inherit (netsurf-buildsystem.meta) maintainers platforms;
    description = "Generalised utility library for netsurf browser";
    homepage = "https://www.netsurf-browser.org/";
    license = lib.licenses.mit;
  };
})
