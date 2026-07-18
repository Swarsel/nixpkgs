{
  lib,
  stdenv,
  enchant,
  fetchgit,
  gitUpdater,
  gtkmm4,
  libchamplain_libsoup3,
  libgcrypt,
  libshumate,
  meson,
  ninja,
  pkg-config,
  shared-mime-info,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lifeograph";
  version = "3.0.4";

  src = fetchgit {
    url = "https://git.launchpad.net/lifeograph";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Zo3bMIAao055YhhIFR8AH43lMi6T82PrcYR3Cis/yK0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    shared-mime-info # for update-mime-database
    wrapGAppsHook4
  ];

  buildInputs = [
    libgcrypt
    enchant
    gtkmm4
    libchamplain_libsoup3
    libshumate
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Off-line and private journal and note taking application";
    homepage = "https://lifeograph.sourceforge.net/doku.php?id=start";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ kyehn ];
    platforms = lib.platforms.linux;
    mainProgram = "lifeograph";
  };
})
