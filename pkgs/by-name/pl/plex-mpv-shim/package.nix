{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  mpv-shim-default-shaders,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "plex-mpv-shim";
  version = "1.11.0-unstable-2025-03-17";

  src = fetchFromGitHub {
    owner = "iwalton3";
    repo = "plex-mpv-shim";
    rev = "fb1f1f3325285e33f9ce3425e9361f5f99277d9a"; # Fetch from this commit to include fixes for python library issues. Should be reverted to release 1.12.0
    hash = "sha256-tk+bIS93Y726sbrRXEyS7+4ku+g40Z7Aj0++wItjW2s=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  propagatedBuildInputs = with python3Packages; [
    mpv
    requests
    python-mpv-jsonipc
    pystray
    tkinter
  ];

  # does not contain tests
  doCheck = false;

  postInstall = ''
    # put link to shaders where upstream package expects them
    ln -s ${mpv-shim-default-shaders}/share/mpv-shim-default-shaders $out/${python3Packages.python.sitePackages}/plex_mpv_shim/default_shader_pack
  '';

  # needed for pystray to access appindicator using GI
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  format = "setuptools";

  meta = {
    description = "Allows casting of videos to MPV via the Plex mobile and web app";
    homepage = "https://github.com/iwalton3/plex-mpv-shim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ devusb ];
    platforms = lib.platforms.linux;
    mainProgram = "plex-mpv-shim";
  };
}
