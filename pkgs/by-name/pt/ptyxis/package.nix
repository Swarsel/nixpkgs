{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  json-glib,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  pcre2,
  pkg-config,
  vte-gtk4,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ptyxis";
  version = "50.1";

  src = fetchFromGitLab {
    owner = "chergert";
    repo = "ptyxis";
    tag = finalAttrs.version;
    hash = "sha256-SHp+2hYEYoKi5I4XuTwL818Kil812tOtuHNXCKoAJCk=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    json-glib
    vte-gtk4
    libportal-gtk4
    pcre2
  ];

  meta = {
    description = "Terminal for GNOME with first-class support for containers";
    homepage = "https://gitlab.gnome.org/chergert/ptyxis";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "ptyxis";
  };
})
