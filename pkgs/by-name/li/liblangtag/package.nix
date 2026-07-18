{
  lib,
  stdenv,
  fetchurl,
  autoconf-archive,
  autoreconfHook,
  gettext,
  glib,
  gnome-common,
  gobject-introspection,
  gtk-doc,
  libxml2,
  pkg-config,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "liblangtag";
  version = "0.6.8";

  # Artifact tarball contains lt-localealias.h needed for darwin
  src = fetchurl {
    url = "https://gitlab.com/tagoh/liblangtag/-/releases/${version}/downloads/liblangtag-${version}.tar.bz2";
    hash = "sha256-qWl1t53dj+9tkpXAg/4/GvoaiJilcjXUBpJVreROXPI=";
  };

  postPatch = ''
    gtkdocize
    cp "${core_zip}" data/core.zip
    touch data/stamp-core-zip
    cp "${language_subtag_registry}" data/language-subtag-registry
  '';

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    gtk-doc
    gettext
    pkg-config
    unzip
    gobject-introspection
  ];

  buildInputs = [
    gettext
    glib
    libxml2
    gnome-common
  ];

  configureFlags = [
    "ac_cv_va_copy=1"
  ]
  ++ lib.optional (
    stdenv.hostPlatform.libc == "glibc"
  ) "--with-locale-alias=${stdenv.cc.libc}/share/locale/locale.alias";

  core_zip = fetchurl {
    hash = "sha256-BsfGmNb9jWfO+sFaAgawEJsA4O8WNvhvhESfqVlWH3Q=";
    # please update if an update is available
    url = "http://www.unicode.org/Public/cldr/48/core.zip";
  };

  language_subtag_registry = fetchurl {
    hash = "sha256-xy94jbBKP0Ig7yOPutSviCA6uryx7PW2b1lBIPk2+6Q=";
    url = "https://web.archive.org/web/20241120202537id_/https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry";
  };

  meta = {
    description = "Interface library to access tags for identifying languages";
    homepage = "https://gitlab.com/tagoh/liblangtag";
    changelog = "https://gitlab.com/tagoh/liblangtag/-/blob/${version}/NEWS";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
  };
}
