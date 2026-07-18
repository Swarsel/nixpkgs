{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gshogi";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "johncheetham";
    repo = "gshogi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EPOIYPSFAhilxuZeYfuZ4Cd29ReJs/E4KNF5/lyzbxs=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
  ];

  doCheck = false; # no tests available

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    pygobject3
    pycairo
  ];

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Graphical implementation of the Shogi board game, also known as Japanese Chess";
    homepage = "http://johncheetham.com/projects/gshogi/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "gshogi";
  };
})
