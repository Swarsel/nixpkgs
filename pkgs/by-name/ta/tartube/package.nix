{
  lib,
  fetchFromGitHub,
  aria2,
  ffmpeg,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  libnotify,
  pango,
  python3Packages,
  wrapGAppsHook3,
  youtube-dl,
}:

python3Packages.buildPythonApplication rec {
  pname = "tartube";
  version = "2.5.164";

  src = fetchFromGitHub {
    owner = "axcore";
    repo = "tartube";
    tag = "v${version}";
    sha256 = "sha256-PPvbdxxGUYUKL+5exO5+iO5ObJgjzFejZIIDA17hvYo=";
  };

  postPatch = ''
    sed -i "/^\s*'pgi',$/d" setup.py
  '';

  strictDeps = false;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gdk-pixbuf
    gtk3
    glib
    libnotify
    pango
  ];

  propagatedBuildInputs = with python3Packages; [
    moviepy
    pygobject3
    pyxdg
    requests
    feedparser
    playsound
    ffmpeg
    matplotlib
    aria2
  ];

  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/{man/man1,applications,pixmaps}
    cp pack/tartube.1 $out/share/man/man1
    cp pack/tartube.desktop $out/share/applications
    cp pack/tartube.{png,xpm} $out/share/pixmaps
  '';

  format = "setuptools";

  makeWrapperArgs = [
    "--prefix PATH : ${lib.makeBinPath [ youtube-dl ]}"
  ];

  meta = {
    description = "GUI front-end for youtube-dl";
    homepage = "https://tartube.sourceforge.io/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.linux;
    mainProgram = "tartube";
  };
}
