{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  glib,
  gtk3,
  json-glib,
  libgee,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "remontoire";
  version = "unstable-2022-06-19";

  src = fetchFromGitHub {
    owner = "regolith-linux";
    repo = "remontoire";
    rev = "68d562c78d6e0094ca744bd7161c308f583e93e";
    hash = "sha256-Cb6tzTGZdQA9oA04DO/xLBw5F+FRj5BM2Aa62YWGmZA=";
  };

  postPatch = ''
    chmod +x build-aux/meson/postinstall.py
    patchShebangs build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    python3
    vala
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    gtk3
    json-glib
    libgee
  ];

  meta = {
    description = "Small GTK app for presenting keybinding hints";
    homepage = "https://github.com/regolith-linux/remontoire";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aacebedo ];
    platforms = lib.platforms.linux;
    mainProgram = "remontoire";
  };
})
