{
  lib,
  fetchFromGitHub,
  cava,
  desktop-file-utils,
  gobject-introspection,
  gst_all_1,
  gtk4,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cavasik";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "TheWisker";
    repo = "Cavasik";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O8rFtqzmDktXKF3219RAo1yxqjfPm1qkHhAyoT7N8AU=";
  };

  postPatch = ''
    substituteInPlace src/cava.py \
      --replace-fail '"cava"' '"${lib.getExe cava}"'
  '';

  nativeBuildInputs = [
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gtk4
    libadwaita
  ];

  checkPhase = ''
    runHook preCheck

    meson test --print-errorlog

    runHook postCheck
  '';

  preFixup = ''
    makeWrapperArgs+=(''${gappsWrapperArgs[@]})
  '';

  dependencies = with python3Packages; [
    pycairo
    pydbus
    pygobject3
  ];

  dontWrapGApps = true;
  pyproject = false; # Built with meson
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Audio visualizer based on CAVA with extended capabilities";
    homepage = "https://github.com/TheWisker/Cavasik";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ starryreverie ];
    mainProgram = "cavasik";
  };
})
