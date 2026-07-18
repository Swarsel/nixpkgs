{
  lib,
  fetchFromGitHub,
  blueprint-compiler,
  desktop-file-utils,
  gobject-introspection,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "escambo";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "CleoMenezesJr";
    repo = "escambo";
    rev = finalAttrs.version;
    hash = "sha256-jMlix8nlCaVLZEhqzb6LRNrD3DUZMTIjqrRKo6nFbQA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    blueprint-compiler
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
    gtksourceview5
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pygobject3
    requests
  ];

  dontWrapGApps = true;
  pyproject = false; # built with meson

  meta = {
    description = "HTTP-based APIs test application for GNOME";
    homepage = "https://github.com/CleoMenezesJr/escambo";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "escambo";
  };
})
