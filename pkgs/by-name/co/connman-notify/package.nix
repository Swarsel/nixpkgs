{
  lib,
  fetchFromGitLab,
  glib,
  gobject-introspection,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "connman-notify";
  version = "2019-10-05";

  src = fetchFromGitLab {
    owner = "wavexx";
    repo = "connman-notify";
    rev = "24b10a51721b54d932f4cd61ef2756423768c015";
    hash = "sha256-EsF+Ckjojnn2o5PCDIexKrNIYxcIM1CZUNaTEIwvq8w=";
  };

  strictDeps = false;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [ glib ];

  installPhase = ''
    install -D -t $out/bin connman-notify
    install -D -t $out/share/doc README.rst
  '';

  pyproject = false;

  pythonPath = with python3Packages; [
    dbus-python
    pygobject3
  ];

  meta = {
    description = "Desktop notification integration for connman";
    homepage = "https://gitlab.com/wavexx/connman-notify";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
    mainProgram = "connman-notify";
  };
}
