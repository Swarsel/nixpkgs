{
  lib,
  fetchFromGitHub,
  libsForQt5,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hue-plus";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "kusti8";
    repo = "hue-plus";
    tag = "v.${finalAttrs.version}"; # Only the latest tag uses a . between v and 1.
    hash = "sha256-dDIJXhB3rmKnawOYJHE7WK38b0M5722zA+yLgpEjDyI=";
  };

  nativeBuildInputs = [ libsForQt5.wrapQtAppsHook ];
  buildInputs = [ libsForQt5.qtbase ];

  propagatedBuildInputs = with python3Packages; [
    pyserial
    pyqt5
    pyaudio
    appdirs
    setuptools
  ];

  build-system = with python3Packages; [ setuptools ];
  dontWrapQtApps = true;

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ];

  pyproject = true;

  meta = {
    description = "Windows and Linux driver in Python for the NZXT Hue+";

    longDescription = ''
      A cross-platform driver in Python for the NZXT Hue+. Supports all functionality except FPS, CPU, and GPU lighting.
    '';

    homepage = "https://github.com/kusti8/hue-plus";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ garaiza-93 ];
    mainProgram = "hue";
  };
})
