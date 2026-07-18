{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  glib,
  gobject-introspection,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
let
  version = "0.5.1";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "pigment";

  src = fetchFromGitHub {
    owner = "Jeffser";
    repo = "Pigment";
    tag = version;
    hash = "sha256-tWWDX1njnI1FOZhTUE1i+5pqZeLZFzHBrfoGFHCKnX0=";
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

  buildInputs = [
    gtk4
    libadwaita
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;

  pythonPath = with python3Packages; [
    pygobject3
    colorthief
    pydbus
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Extract color palettes from your images";
    homepage = "https://jeffser.com/pigment/";
    changelog = "https://github.com/Jeffser/Pigment/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.da157 ];
    platforms = lib.platforms.linux;
    mainProgram = "pigment";
    downloadPage = "https://github.com/Jeffser/Pigment";
  };
}
