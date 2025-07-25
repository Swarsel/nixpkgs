{
  lib,
  fetchFromGitHub,
  wrapGAppsHook3,
  gettext,
  python3Packages,
  adwaita-icon-theme,
  gtk3,
  glib,
  gdk-pixbuf,
  gsettings-desktop-schemas,
  gobject-introspection,
}:

let
  inherit (python3Packages)
    buildPythonApplication
    isPy3k
    dbus-python
    pygobject3
    mpd2
    setuptools
    ;
in
buildPythonApplication rec {
  pname = "sonata";
  version = "1.7.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "multani";
    repo = "sonata";
    tag = "v${version}";
    sha256 = "sha256-80F2dVaRawnI0E+GzaxRUudaLWWHGUjICCEbXHVGy+E=";
  };

  disabled = !isPy3k;

  nativeBuildInputs = [
    gettext
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    adwaita-icon-theme
    gsettings-desktop-schemas
    gtk3
    gdk-pixbuf
  ];

  build-system = [ setuptools ];

  # The optional tagpy dependency (for editing metadata) is not yet
  # included because it's difficult to build.
  pythonPath = [
    dbus-python
    mpd2
    pygobject3
    setuptools # pkg_resources is imported during runtime
  ];

  postPatch = ''
    # Remove "Local MPD" tab which is not suitable for NixOS.
    sed -i '/localmpd/d' sonata/consts.py
  '';

  meta = {
    description = "Elegant client for the Music Player Daemon";
    mainProgram = "sonata";
    longDescription = ''
      Sonata is an elegant client for the Music Player Daemon.

      Written in Python and using the GTK 3 widget set, its features
      include:

       - Expanded and collapsed views
       - Automatic remote and local album art
       - Library browsing by folders, or by genre/artist/album
       - User-configurable columns
       - Automatic fetching of lyrics
       - Playlist and stream support
       - Support for editing song tags (not in NixOS version)
       - Drag and drop to copy files
       - Popup notification
       - Library and playlist searching, filter as you type
       - Audioscrobbler (last.fm) 1.2 support
       - Multiple MPD profiles
       - Keyboard friendly
       - Support for multimedia keys
       - Commandline control
       - Available in 24 languages
    '';
    homepage = "https://www.nongnu.org/sonata/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
  };
}
