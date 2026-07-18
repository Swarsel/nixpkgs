{
  lib,
  # dependencies
  aiohttp,
  asyncssh,
  atomicwrites,
  bcrypt,
  buildPythonPackage,
  chardet,
  cloudpickle,
  cookiecutter,
  diff-match-patch,
  fetchPypi,
  fzf,
  intervaltree,
  ipython-pygments-lexers,
  jedi,
  jellyfish,
  keyring,
  matplotlib,
  nbconvert,
  numpy,
  numpydoc,
  packaging,
  pickleshare,
  psutil,
  pygithub,
  pygments,
  pylint-venv,
  pyls-spyder,
  pyopengl,
  pyqt6,
  # nativeBuildInputs
  pyqt6-webengine,
  python-lsp-black,
  python-lsp-ruff,
  python-lsp-server,
  pyuca,
  pyzmq,
  qdarkstyle,
  qstylizer,
  qt6,
  qtawesome,
  qtconsole,
  qtpy,
  rope,
  rtree,
  scipy,
  # build-system
  setuptools,
  spyder-kernels,
  superqt,
  textdistance,
  three-merge,
  watchdog,
  yarl,
}:

buildPythonPackage rec {
  pname = "spyder";
  version = "6.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bgkiihfqqIHnYes5gvIvAdQ7arUAm7NmGLaqnP/Ml40=";
  };

  patches = [ ./dont-clear-pythonpath.patch ];
  nativeBuildInputs = [ qt6.wrapQtAppsHook ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  env.SPYDER_QT_BINDING = "pyqt6";
  # There is no test for spyder
  doCheck = false;

  postInstall = ''
    # Add Python libs to env so Spyder subprocesses
    # created to run compute kernels don't fail with ImportErrors
    wrapProgram $out/bin/spyder --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    asyncssh
    atomicwrites
    bcrypt
    chardet
    cloudpickle
    cookiecutter
    diff-match-patch
    fzf
    intervaltree
    ipython-pygments-lexers
    jedi
    jellyfish
    keyring
    matplotlib
    nbconvert
    numpy
    numpydoc
    packaging
    pickleshare
    psutil
    pygithub
    pygments
    pylint-venv
    pyls-spyder
    pyopengl
    pyqt6-webengine
    python-lsp-black
    python-lsp-ruff
    python-lsp-server
    pyuca
    pyzmq
    qdarkstyle
    qstylizer
    qtawesome
    qtconsole
    qtpy
    rope
    rtree
    scipy
    spyder-kernels
    superqt
    textdistance
    three-merge
    watchdog
    yarl
    pyqt6
  ]
  ++ python-lsp-server.optional-dependencies.all;

  dontWrapQtApps = true;
  pyproject = true;

  pythonRelaxDeps = [
    "ipython"
    "jedi"
    "python-lsp-server"
  ];

  meta = {
    description = "Scientific python development environment";

    longDescription = ''
      Spyder (previously known as Pydee) is a powerful interactive development
      environment for the Python language with advanced editing, interactive
      testing, debugging and introspection features.
    '';

    homepage = "https://www.spyder-ide.org/";
    changelog = "https://github.com/spyder-ide/spyder/blob/v${version}/changelogs/Spyder-6.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "spyder";
    downloadPage = "https://github.com/spyder-ide/spyder/releases";
  };
}
