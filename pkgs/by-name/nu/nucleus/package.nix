{
  lib,
  appstream-glib,
  blueprint-compiler,
  desktop-file-utils,
  fetchFromCodeberg,
  glib,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
let
  version = "3";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "nucleus";

  src = fetchFromCodeberg {
    owner = "lo-vely";
    repo = "nucleus";
    tag = "v${version}";
    hash = "sha256-0IuFKOadweGYvflCN2c1hvW+X4GzvqG8ZRhPzuVSBr8=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    glib
    desktop-file-utils
    appstream-glib
    blueprint-compiler
  ];

  buildInputs = [
    libadwaita
  ];

  dependencies = with python3Packages; [
    pygobject3
  ];

  dontWrapGApps = true;
  makeWrapperArgs = [ "\${gappsWrapperArgs[@]}" ];
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Unofficial GNOME Periodic Table";
    homepage = "https://codeberg.org/lo-vely/nucleus";
    changelog = "https://codeberg.org/lo-vely/nucleus/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.da157 ];
    platforms = lib.platforms.linux;
    mainProgram = "nucleus";
  };
}
