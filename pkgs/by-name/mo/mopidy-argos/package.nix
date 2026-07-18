{
  lib,
  stdenv,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gobject-introspection,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
}:
python3Packages.buildPythonApplication rec {
  pname = "mopidy-argos";
  version = "1.17.0";

  src = fetchFromGitHub {
    owner = "orontee";
    repo = "argos";
    tag = "v${version}";
    hash = "sha256-U6frnCor14dIDtgwn83dln+76NoIqBqPiwYLkVaa/x8=";
  };

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    appstream-glib
    gobject-introspection
    desktop-file-utils
    wrapGAppsHook3
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    aiohttp
    pycairo
    pygobject3
    pyxdg
    zeroconf
  ];

  dontWrapGApps = true;
  pyproject = false; # Built with meson

  meta = {
    description = "Gtk front-end to control a Mopidy server";
    homepage = "https://github.com/orontee/argos";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.hufman ];
    mainProgram = "argos";
  };
}
