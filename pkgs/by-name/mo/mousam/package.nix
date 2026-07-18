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
  pname = "mousam";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "amit9838";
    repo = "mousam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3x4bi3P8zw+A+MUaBd4ByESrzCEP21Qa9CLaUYGARew=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    pygobject3
    requests
  ];

  dontWrapGApps = true;
  # built with meson, not a python format
  pyproject = false;

  meta = {
    description = "Beautiful and lightweight weather app based on Python and GTK4";
    homepage = "https://amit9838.github.io/mousam";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "mousam";
  };
})
