{
  lib,
  fetchFromGitHub,
  ffmpeg-full,
  gobject-introspection,
  gtk3,
  nix-update-script,
  pango,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "escrotum";
  version = "1.0.1-unstable-2020-12-07";

  src = fetchFromGitHub {
    owner = "Roger";
    repo = "escrotum";
    rev = "a41d0f11bb6af4f08e724b8ccddf8513d905c0d1";
    sha256 = "sha256-z0AyTbOEE60j/883X17mxgoaVlryNtn0dfEB0C18G2s=";
  };

  outputs = [
    "out"
    "man"
  ];

  # Cannot find pango without strictDeps = false
  strictDeps = false;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    pango
  ];

  postInstall = ''
    mkdir -p $man/share/man/man1
    cp man/escrotum.1 $man/share/man/man1/
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pygobject3
    xcffib
    pycairo
    numpy
  ];

  makeWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ ffmpeg-full ]}" ];
  pyproject = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Linux screen capture using pygtk, inspired by scrot";
    homepage = "https://github.com/Roger/escrotum";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "escrotum";
  };
}
