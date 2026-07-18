{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  python3,
  wrapGAppsHook3,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "discover-overlay";
  version = "0.7.9";

  src = fetchFromGitHub {
    owner = "trigg";
    repo = "Discover";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z554/zRikZztdD4NZiDDjMWgIlnQDGkemlA3ONRhqR8=";
  };

  postPatch = ''
    substituteInPlace discover_overlay/image_getter.py \
      --replace-fail /usr $out
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    gtk-layer-shell
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pulsectl-asyncio
    pycairo
    pygobject3
    websocket-client
    pyxdg
    requests
    pillow
    setuptools
    python-xlib
  ];

  doCheck = false;
  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--set DISPLAY ':0.0'"
  ];

  pyproject = true;

  meta = {
    description = "Yet another discord overlay for linux";
    homepage = "https://github.com/trigg/Discover";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dragonginger ];
    platforms = lib.platforms.linux;
    mainProgram = "discover-overlay";
  };
})
