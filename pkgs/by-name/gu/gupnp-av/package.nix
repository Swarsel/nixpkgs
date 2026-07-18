{
  lib,
  stdenv,
  fetchurl,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  libxml2,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gupnp-av";
  version = "0.14.5";

  src = fetchurl {
    url = "mirror://gnome/sources/gupnp-av/${lib.versions.majorMinor finalAttrs.version}/gupnp-av-${finalAttrs.version}.tar.xz";
    sha256 = "k5GPz1r1Kf2ls9LZ/Dt3zZPfiAZJObgvJJ9Vd9jeHAI=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gi-docgen
    gobject-introspection
    vala
  ];

  propagatedBuildInputs = [
    glib
    libxml2
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  doCheck = true;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc/gupnp-av-1.0" "$devdoc"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gupnp-av";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Collection of helpers for building AV (audio/video) applications using GUPnP";
    homepage = "http://gupnp.org/";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.unix;
  };
})
