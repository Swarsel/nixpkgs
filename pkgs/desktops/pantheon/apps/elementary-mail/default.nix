{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-gtk-theme,
  elementary-icon-theme,
  evolution-data-server,
  fetchpatch,
  folks,
  glib-networking,
  granite,
  gtk3,
  libgee,
  libhandy,
  libportal-gtk3,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "elementary-mail";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "mail";
    tag = finalAttrs.version;
    hash = "sha256-6DY8pJXPXz6uaBKR/qLxYpAQfpzlzi/wtj1douhSjpQ=";
  };

  patches = [
    # Adapt to libcamel API changes in 3.57.1
    # https://github.com/elementary/mail/pull/1023
    (fetchpatch {
      hash = "sha256-NFZVvKJyPTV+lRcefTIgm2jOmCfrY+TlawDYzGTBd7Y=";
      url = "https://github.com/elementary/mail/commit/8cb5bb87ceca9000c2a556bafeb059b9f1cbf2f1.patch";
    })
  ];

  nativeBuildInputs = [
    libxml2
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook3
  ];

  buildInputs = [
    elementary-icon-theme
    evolution-data-server
    folks
    glib-networking
    granite
    gtk3
    libgee
    libhandy
    libportal-gtk3
    webkitgtk_4_1
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # The GTK theme is hardcoded.
      --prefix XDG_DATA_DIRS : "${elementary-gtk-theme}/share"
      # The icon theme is hardcoded.
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mail app designed for elementary OS";
    homepage = "https://github.com/elementary/mail";
    changelog = "https://github.com/elementary/mail/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.mail";
    teams = [ lib.teams.pantheon ];
  };
})
