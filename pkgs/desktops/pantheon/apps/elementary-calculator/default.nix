{
  lib,
  stdenv,
  fetchFromGitHub,
  elementary-gtk-theme,
  elementary-icon-theme,
  granite7,
  gtk4,
  libgee,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "elementary-calculator";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "elementary";
    repo = "calculator";
    rev = version;
    sha256 = "sha256-XBOe3v6lKoICgEh78JoVH0Ojs8tr5PxKHQGk63MX6pQ=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    wrapGAppsHook4
  ];

  buildInputs = [
    elementary-icon-theme
    granite7
    gtk4
    libgee
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      # The GTK theme is hardcoded.
      --prefix XDG_DATA_DIRS : "${elementary-gtk-theme}/share"
      # The icon theme is hardcoded.
      --prefix XDG_DATA_DIRS : "$XDG_ICON_DIRS"
    )
  '';

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Calculator app designed for elementary OS";
    homepage = "https://github.com/elementary/calculator";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "io.elementary.calculator";
    teams = [ lib.teams.pantheon ];
  };
}
