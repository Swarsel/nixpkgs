{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  glib-networking,
  gtk4,
  json-glib,
  libadwaita,
  libarchive,
  libgee,
  libsoup_3,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "protonplus";
  version = "0.5.21";

  src = fetchFromGitHub {
    owner = "Vysp3r";
    repo = "protonplus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-elc2hDAiMT15bAZW4z55K9EsTRmHeU3YBccTx2GMTIE=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    glib-networking
    gtk4
    json-glib
    libadwaita
    libarchive
    libgee
    libsoup_3
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple Wine and Proton-based compatibility tools manager";
    homepage = "https://github.com/Vysp3r/ProtonPlus";
    changelog = "https://github.com/Vysp3r/ProtonPlus/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ getchoo ];
    platforms = lib.platforms.linux;
    mainProgram = "protonplus";
  };
})
