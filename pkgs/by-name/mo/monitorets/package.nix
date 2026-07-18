{
  lib,
  fetchFromGitHub,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "monitorets";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "jorchube";
    repo = "monitorets";
    tag = finalAttrs.version;
    hash = "sha256-Y6cd9Wf2IzHwdxzLUP/U4rervlPUr8s2gKSW8y5I7bg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [ libadwaita ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pygobject3
    xdg
    psutil
  ];

  dontWrapGApps = true;
  # built with meson, not a python format
  pyproject = false;

  meta = {
    description = "Simple and quick view at the usage of your computer resources";
    homepage = "https://github.com/jorchube/monitorets";

    license = with lib.licenses; [
      gpl3Plus
      cc0
    ];

    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "monitorets";
  };
})
