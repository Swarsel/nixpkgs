{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  avahi,
  curl,
  dbus-glib,
  gettext,
  gtk3,
  intltool,
  libmpdclient,
  libxml2,
  pkg-config,
  taglib,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "ario";
  version = "1.6";

  src = fetchurl {
    url = "mirror://sourceforge/ario-player/${pname}-${version}.tar.gz";
    sha256 = "16nhfb3h5pc7flagfdz7xy0iq6kvgy6h4bfpi523i57rxvlfshhl";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    gettext
    intltool
    wrapGAppsHook3
  ];

  buildInputs = [
    avahi
    curl
    dbus-glib
    gtk3
    libmpdclient
    libxml2
    taglib
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    for file in $out/lib/ario/plugins/*.dylib; do
      ln -s $file $out/lib/ario/plugins/$(basename $file .dylib).so
    done
  '';

  preAutoreconf = ''
    gettextize --force --copy
  '';

  meta = {
    description = "GTK client for MPD (Music player daemon)";
    homepage = "https://ario-player.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.garrison ];
    platforms = lib.platforms.all;
    mainProgram = "ario";
  };
}
