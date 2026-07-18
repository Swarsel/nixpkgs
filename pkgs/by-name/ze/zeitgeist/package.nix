{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  automake,
  dbus,
  gettext,
  glib,
  gobject-introspection,
  gtk3,
  json-glib,
  librdf_raptor2,
  libtool,
  pkg-config,
  python3,
  sqlite,
  vala,
  pythonSupport ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zeitgeist";
  version = "1.0.4";

  src = fetchFromGitLab {
    owner = "zeitgeist";
    repo = "zeitgeist";
    rev = "v${finalAttrs.version}";
    sha256 = "kG1N8DXgjYAJ8fbrGHsp7eTqB20H5smzRnW0PSRUYR0=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ]
  ++ lib.optional pythonSupport "py";

  postPatch = ''
    patchShebangs data/ontology2code
  '';

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    gettext
    gobject-introspection
    vala
    python3
  ];

  buildInputs = [
    glib
    sqlite
    dbus
    gtk3
    json-glib
    librdf_raptor2
    python3.pkgs.rdflib
  ];

  configureFlags = [
    "--disable-telepathy"
  ];

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  postFixup = lib.optionalString pythonSupport ''
    moveToOutput lib/${python3.libPrefix} "$py"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Service which logs the users’s activities and events";
    homepage = "https://zeitgeist.freedesktop.org/";
    license = lib.licenses.lgpl21Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.freedesktop ];
  };
})
