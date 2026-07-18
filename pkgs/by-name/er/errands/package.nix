{
  lib,
  fetchFromGitHub,
  appstream,
  desktop-file-utils,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  libadwaita,
  libportal,
  libsecret,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "errands";
  version = "46.2.10";

  src = fetchFromGitHub {
    owner = "mrvladus";
    repo = "Errands";
    tag = finalAttrs.version;
    hash = "sha256-YgKn6tBW1gG6H1zEAzaQjJWzSXh4Na44yZ7lfAnqUFA=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
    meson
    ninja
    pkg-config
    appstream
    gtk4
  ];

  buildInputs = [
    libadwaita
    libportal
    libsecret
    gtksourceview5
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    lxml
    caldav
    pycryptodomex
    urllib3
    requests
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  pyproject = false;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Manage your tasks";
    homepage = "https://github.com/mrvladus/Errands";
    changelog = "https://github.com/mrvladus/Errands/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      sund3RRR
    ];

    mainProgram = "errands";
    teams = [ lib.teams.gnome-circle ];
  };
})
