{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
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
  version = "1.5.3";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "poliedros";

  src = fetchFromGitHub {
    owner = "kriptolix";
    repo = "Poliedros";
    tag = "v${version}";
    hash = "sha256-PZKmxy9Pc0bPCXUmSZL2ETuJbmN3pebMwak3fRuj9AU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
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
    description = "Multi-type dice roller";
    homepage = "https://github.com/kriptolix/Poliedros";
    changelog = "https://github.com/kriptolix/Poliedros/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.da157 ];
    mainProgram = "poliedros";
  };
}
