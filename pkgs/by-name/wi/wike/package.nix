{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  glib,
  glib-networking,
  gobject-introspection,
  gtk4,
  libadwaita,
  librsvg,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wike";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "hugolabe";
    repo = "Wike";
    tag = finalAttrs.version;
    hash = "sha256-FD0XucAp5SMXTsp+FrsGNYcmatSWiD9U9lAHRB1Aj3k=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    appstream-glib
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    gtk4
    librsvg
    libadwaita
    glib-networking
    webkitgtk_6_0
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/share/wike" "$out ''${pythonPath[*]}"
  '';

  dependencies = with python3Packages; [
    requests
    pygobject3
  ];

  # prevent double wrapping
  dontWrapGApps = true;
  pyproject = false; # built with meson

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wikipedia Reader for the GNOME Desktop";
    homepage = "https://hugolabe.github.io/Wike";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ samalws ];
    platforms = lib.platforms.linux;
    mainProgram = "wike";
    teams = [ lib.teams.gnome-circle ];
  };
})
