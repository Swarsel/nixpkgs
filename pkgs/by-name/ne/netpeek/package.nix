{
  lib,
  fetchFromGitHub,
  appstream,
  desktop-file-utils,
  gobject-introspection,
  libadwaita,
  libportal-gtk4,
  meson,
  ninja,
  nix-update-script,
  python3Packages,
  wrapGAppsHook4,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "netpeek";
  version = "0.2.7";

  src = fetchFromGitHub {
    owner = "ZingyTomato";
    repo = "NetPeek";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Cc8x9diBeKIk1G5fU1WHtgmUwCCbAwIrw8zEQScKlZ4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    appstream
    desktop-file-utils
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    libportal-gtk4
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  __structuredAttrs = true;

  dependencies = with python3Packages; [
    pygobject3
    ping3
    python-nmap
  ];

  dontWrapGApps = true;
  pyproject = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern network scanner for GNOME";
    homepage = "https://github.com/ZingyTomato/NetPeek";
    changelog = "https://github.com/ZingyTomato/NetPeek/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ Cameo007 ];
    platforms = lib.platforms.linux;
    mainProgram = "netpeek";
  };
})
