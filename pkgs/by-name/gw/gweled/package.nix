{
  lib,
  stdenv,
  clutter,
  clutter-gtk,
  desktop-file-utils,
  fetchgit,
  gsound,
  libgnome-games-support,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gweled";
  version = "1.0-beta1";

  src = fetchgit {
    url = "https://git.launchpad.net/gweled";
    tag = finalAttrs.version;
    hash = "sha256-cm1z6l2tfYBFVFcvsnQ6cI3pQDnJMzn6SUC20gnBF5w=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    clutter
    clutter-gtk
    gsound
    libgnome-games-support
  ];

  configureFlags = [ "--disable-setgid" ];

  meta = {
    description = "Puzzle game similar to Bejeweled or Diamond Mine";
    homepage = "https://gweled.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "gweled";
  };
})
