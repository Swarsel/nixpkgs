{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  libnotify,
  libwnck,
  python3Packages,
  replaceVars,
  wrapGAppsHook3,
}:

python3Packages.buildPythonPackage rec {
  pname = "xborders";
  version = "3.4"; # in version.txt

  src = fetchFromGitHub {
    owner = "deter0";
    repo = "xborder";
    rev = "e74ae532b9555c59d195537934fa355b3fea73c5";
    hash = "sha256-UKsseNkXest6npPqJKvKL0iBWeK+S7zynrDlyXIOmF4=";
  };

  postPatch =
    let
      setup = replaceVars ./setup.py {
        inherit pname version;
        desc = meta.description; # "description" is reserved
      };
    in
    ''
      ln -s ${setup} setup.py
    '';

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    libwnck
    gtk3
    libnotify
  ];

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pycairo
    requests
    pygobject3
  ];

  pyproject = true;

  meta = {
    description = "Active window border replacement for window managers";
    homepage = "https://github.com/deter0/xborder";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ elnudev ];
    platforms = lib.platforms.linux;
    mainProgram = "xborders";
  };
}
