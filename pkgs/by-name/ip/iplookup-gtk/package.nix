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

python3Packages.buildPythonPackage rec {
  pname = "iplookup-gtk";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Bytezz";
    repo = "IPLookup-gtk";
    tag = "v${version}";
    hash = "sha256-pRTN91uwjYu3Li4NbDvJ6l9gikBnXj0j+ApMWpuLUTU=";
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
  ];

  dontWrapGApps = true;
  pyproject = false; # Built with meson

  meta = {
    description = "Find info about an IP address";
    homepage = "https://github.com/Bytezz/IPLookup-gtk";
    changelog = "https://github.com/Bytezz/IPLookup-gtk/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "iplookup";
  };
}
