{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-gtk-theme,
  elementary-icon-theme,
  gala,
  gettext,
  glib,
  granite,
  gtk3,
  json-glib,
  libgee,
  meson,
  mutter,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wayland,
  wayland-scanner,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "wingpanel";
  version = "8.0.4";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "wingpanel";
    tag = version;
    hash = "sha256-+m1TydQtbXuA7uS6hZVC8z6JgOUxDh/QXL/4tROHhwk=";
  };

  patches = [
    ./indicators.patch
  ];

  nativeBuildInputs = [
    gettext
    meson
    ninja
    pkg-config
    vala
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    elementary-icon-theme
    gala
    granite
    json-glib
    libgee
    mutter
    wayland
  ];

  propagatedBuildInputs = [
    glib
    gtk3
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # this GTK theme is required
      --prefix XDG_DATA_DIRS : "${elementary-gtk-theme}/share"

      # the icon theme is required
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
    )
  '';

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Extensible top panel for Pantheon";

    longDescription = ''
      Wingpanel is an empty container that accepts indicators as extensions,
      including the applications menu.
    '';

    homepage = "https://github.com/elementary/wingpanel";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.wingpanel";
    teams = [ lib.teams.pantheon ];
  };
}
