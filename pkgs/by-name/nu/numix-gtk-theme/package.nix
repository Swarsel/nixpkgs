{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gitUpdater,
  glib,
  gtk-engine-murrine,
  libxml2,
  sassc,
}:

stdenv.mkDerivation {
  pname = "numix-gtk-theme";
  version = "unstable-2021-06-08";

  src = fetchFromGitHub {
    owner = "numixproject";
    repo = "numix-gtk-theme";
    rev = "ad4b345cb19edba96bec72d6dc97ed1b568755a8";
    hash = "sha256-7KX5xC6Gr6azqL2qyc8rYb3q9UhcGco2uEfltsQ+mgo=";
  };

  postPatch = ''
    substituteInPlace Makefile --replace '$(DESTDIR)'/usr $out
    patchShebangs .
  '';

  nativeBuildInputs = [
    sassc
    glib
    libxml2
    gdk-pixbuf
  ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Modern flat theme with a combination of light and dark elements (GNOME, Unity, Xfce and Openbox)";
    homepage = "https://numixproject.github.io";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.all;
  };
}
