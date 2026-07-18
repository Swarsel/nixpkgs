{
  lib,
  stdenv,
  fetchurl,
  fetchDebianPatch,
  gettext,
  gspell,
  gtk3,
  libarchive,
  libgringotts,
  libical,
  libnotify,
  libxml2,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "osmo";
  version = "0.4.4";

  src = fetchurl {
    url = "mirror://sourceforge/osmo-pim/osmo-${finalAttrs.version}.tar.gz";
    sha256 = "19h3dnjgqbawnvgnycyp4n5b6mjsp5zghn3b69b6f3xa3fyi32qy";
  };

  patches = [
    (fetchDebianPatch {
      pname = "osmo";
      version = "0.4.4";
      debianRevision = "3";
      hash = "sha256-2T34wYczOTc57tjt3w91q8TDtQZqLpwYOsr8JKpYs0c=";
      patch = "gcc-15.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libxml2
    libical
    libnotify
    libarchive
    gspell
    webkitgtk_4_1
    libgringotts
  ];

  meta = {
    description = "Handy personal organizer";
    homepage = "https://clayo.org/osmo/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    mainProgram = "osmo";
  };
})
