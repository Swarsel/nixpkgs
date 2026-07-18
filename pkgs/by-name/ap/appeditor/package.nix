{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  glib,
  gtk3,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pantheon,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appeditor";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "donadigo";
    repo = "appeditor";
    tag = finalAttrs.version;
    sha256 = "sha256-A0YasHw5osGrgUPiUPuRBnv1MR/Pth6jVHGEx/klOGY=";
  };

  postPatch = ''
    chmod +x meson/post_install.py
    patchShebangs meson/post_install.py
  '';

  nativeBuildInputs = [
    gettext
    meson
    ninja
    vala
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    pantheon.granite
    libgee
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Edit the Pantheon desktop application menu";
    homepage = "https://github.com/donadigo/appeditor";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ xiorcale ];
    platforms = lib.platforms.linux;
    mainProgram = "com.github.donadigo.appeditor";
    teams = [ lib.teams.pantheon ];
  };
})
