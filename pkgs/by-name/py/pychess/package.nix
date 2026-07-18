{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gst_all_1,
  gtk3,
  gtksourceview4,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pychess";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "pychess";
    repo = "pychess";
    rev = finalAttrs.version;
    hash = "sha256-MSz5RiPpmlySjljhDlkvXtO6t3UO58zx+uGsV9R6F1A=";
  };

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    wrapGAppsHook3
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    gtk3
    gst_all_1.gst-plugins-base
    gtksourceview4
  ];

  preBuild = ''
    export PYTHONPATH=./lib:$PYTHONPATH
    python pgn2ecodb.py
    python create_theme_preview.py
  '';

  # No tests available.
  doCheck = false;

  postInstall = ''
    cp -r $out/share/pychess/* $out/lib/python*/
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    pycairo
    sqlalchemy
    pexpect
    psutil
    websockets
    ptyprocess
  ];

  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "pychess" ];

  meta = {
    description = "Advanced GTK chess client written in Python";
    homepage = "https://pychess.github.io/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lgbishop ];
    platforms = lib.platforms.linux;
    mainProgram = "pychess";
  };
})
