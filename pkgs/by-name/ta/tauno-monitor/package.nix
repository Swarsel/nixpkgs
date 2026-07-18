{
  lib,
  fetchFromGitHub,
  appstream,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "tauno-monitor";
  version = "0.2.20";

  src = fetchFromGitHub {
    owner = "taunoe";
    repo = "tauno-monitor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rtFnWK1K4S866lgR/lGaTB+REqDExKsEFePX8cwai5E=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    appstream
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  __structuredAttrs = true;

  dependencies = with python3Packages; [
    pygobject3
    pyserial
  ];

  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple serial port monitor";
    homepage = "https://github.com/taunoe/tauno-monitor";
    changelog = "https://github.com/taunoe/tauno-monitor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Cameo007 ];
    platforms = lib.platforms.linux;
    mainProgram = "tauno-monitor";
  };
})
