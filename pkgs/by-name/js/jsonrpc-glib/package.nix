{
  lib,
  stdenv,
  fetchurl,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  json-glib,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation rec {
  pname = "jsonrpc-glib";
  version = "3.44.2";

  src = fetchurl {
    url = "mirror://gnome/sources/jsonrpc-glib/${lib.versions.majorMinor version}/jsonrpc-glib-${version}.tar.xz";
    sha256 = "llSWtuExTzRotIKl2ANA3DsDQKVALXeDytJBVK7nc5Y=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    vala
    gi-docgen
  ];

  buildInputs = [
    glib
    json-glib
  ];

  mesonFlags = [
    "-Denable_gtk_doc=true"
  ];

  # Tests fail non-deterministically
  # https://gitlab.gnome.org/GNOME/jsonrpc-glib/issues/2
  doCheck = false;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Library to communicate using the JSON-RPC 2.0 specification";
    homepage = "https://gitlab.gnome.org/GNOME/jsonrpc-glib";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
}
