{
  lib,
  fetchFromGitHub,
  file,
  gobject-introspection,
  gtk3,
  intltool,
  keybinder3,
  libnotify,
  makeBinaryWrapper,
  nixosTests,
  python3,
  vte,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "terminator";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "gnome-terminator";
    repo = "terminator";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RM/7jUWGDV0EdMyMeLsCrvevH+5hZSJVAKmtalxNKG8=";
  };

  postPatch = ''
    patchShebangs tests po
  '';

  nativeBuildInputs = [
    file
    intltool
    gobject-introspection
    makeBinaryWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    keybinder3
    libnotify
    python3
    vte
  ];

  doCheck = false;

  # HACK: 'wrapPythonPrograms' will add things to the $PATH in the wrapper. This bleeds into the
  # terminal session produced by terminator. To avoid this, we force wrapPythonPrograms to only
  # use gappsWrapperArgs by redefining wrapProgram to ignore its arguments and only apply the
  # wrapper arguments we want it to use.
  # TODO: Adjust wrapPythonPrograms to respect an argument that tells it to leave $PATH alone.
  preFixup = ''
    wrapProgram() {
      wrapProgramBinary "$1" "''${gappsWrapperArgs[@]}"
    }
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    configobj
    dbus-python
    pygobject3
    psutil
    pycairo
  ];

  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "terminatorlib" ];
  passthru.tests.test = nixosTests.terminal-emulators.terminator;

  meta = {
    description = "Terminal emulator with support for tiling and tabs";

    longDescription = ''
      The goal of this project is to produce a useful tool for arranging
      terminals. It is inspired by programs such as gnome-multi-term,
      quadkonsole, etc. in that the main focus is arranging terminals in grids
      (tabs is the most common default method, which Terminator also supports).
    '';

    homepage = "https://github.com/gnome-terminator/terminator";
    changelog = "https://github.com/gnome-terminator/terminator/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.linux;
  };
})
