{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gobject-introspection,
  graphviz,
  gtk3,
  numpy,
  packaging,
  pygobject3,
  python,
  setuptools,
  wrapGAppsHook3,
  xvfb-run,
}:

buildPythonPackage rec {
  pname = "xdot";
  version = "1.6";

  src = fetchFromGitHub {
    owner = "jrfonseca";
    repo = "xdot.py";
    rev = version;
    hash = "sha256-eOuD8q7qN2MAFklIy28lfR0nEMsKDqVO+HE3+M0k5T0=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    graphviz
    gtk3
  ];

  nativeCheckInputs = [ xvfb-run ];

  checkPhase = ''
    runHook preCheck

    xvfb-run -s '-screen 0 800x600x24' ${python.interpreter} test.py

    runHook postCheck
  '';

  # Arguments to be passed to `makeWrapper`, only used by buildPython*
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix PATH : ${lib.makeBinPath [ graphviz ]})
  '';

  build-system = [ setuptools ];

  dependencies = [
    pygobject3
    numpy
    packaging
  ];

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Interactive viewer for graphs written in Graphviz's dot";
    homepage = "https://github.com/jrfonseca/xdot.py";
    license = lib.licenses.lgpl3Plus;
    mainProgram = "xdot";
  };
}
