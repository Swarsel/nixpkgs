{
  lib,
  stdenv,
  fetchurl,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  gtk-doc,
  libgit2,
  libssh2,
  meson,
  ninja,
  pkg-config,
  python3,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgit2-glib";
  version = "1.2.1";

  src = fetchurl {
    url = "mirror://gnome/sources/libgit2-glib/${lib.versions.majorMinor finalAttrs.version}/libgit2-glib-${finalAttrs.version}.tar.xz";
    sha256 = "l0I6d5ACs76HUcdfnXkEnfzMo2FqJhWfwWJIZ3K6eF8=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    chmod +x meson_python_compile.py
    patchShebangs meson_python_compile.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
    gtk-doc
    gobject-introspection
    gi-docgen
  ];

  buildInputs = [
    libssh2
    python3.pkgs.pygobject3 # this should really be a propagated input of python output
  ];

  propagatedBuildInputs = [
    # Required by libgit2-glib-1.0.pc
    libgit2
    glib
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libgit2-glib";
      versionPolicy = "none";
    };
  };

  meta = {
    description = "Glib wrapper library around the libgit2 git access library";
    homepage = "https://gitlab.gnome.org/GNOME/libgit2-glib";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
