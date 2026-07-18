{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch2,
  glib,
  gtk3,
  gtksourceview4,
  intltool,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xpad";
  version = "5.8.0";

  src = fetchurl {
    url = "https://launchpad.net/xpad/trunk/${finalAttrs.version}/+download/xpad-${finalAttrs.version}.tar.bz2";
    hash = "sha256-8mBSMIhQxAaxWtuNhqzTli7xCvIrQnuxpc/07slvguk=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-ipebPkCpgj+5vvFS7QciZgH0CTZS12FdeVILfDReVsY=";
      url = "https://git.launchpad.net/~neil.mayhew/xpad/+git/xpad-1/patch/?id=637c7b51f1b09a28553a926f594f626d363c526a";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
    intltool
  ];

  buildInputs = [
    glib
    gtk3
    gtksourceview4
  ];

  meta = {
    description = "Sticky note application for jotting down things to remember";
    homepage = "https://launchpad.net/xpad";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ michalrus ];
    platforms = lib.platforms.linux;
    mainProgram = "xpad";
  };
})
