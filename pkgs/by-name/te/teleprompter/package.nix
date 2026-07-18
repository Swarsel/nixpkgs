{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gettext,
  glib,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
let
  version = "1.0.1";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "teleprompter";

  src = fetchFromGitHub {
    owner = "Nokse22";
    repo = "teleprompter";
    tag = "v${version}";
    hash = "sha256-KnjZJbTM5EH/0aitqCtohE3Xy4ixOsDMthUn8kWjHq8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    gettext
    glib
    desktop-file-utils
    appstream-glib
    gobject-introspection
  ];

  buildInputs = [ libadwaita ];
  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;
  pythonPath = [ python3Packages.pygobject3 ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Stay on track during speeches";
    homepage = "https://github.com/Nokse22/teleprompter";
    changelog = "https://github.com/Nokse22/teleprompter/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.da157 ];
    mainProgram = "teleprompter";
  };
}
