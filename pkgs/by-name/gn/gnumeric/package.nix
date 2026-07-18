{
  lib,
  stdenv,
  fetchFromGitLab,
  adwaita-icon-theme,
  autoreconfHook,
  bison,
  gettext,
  glib,
  gnome,
  goffice,
  gtk-doc,
  gtk3,
  intltool,
  itstool,
  libxml2,
  perlPackages,
  pkg-config,
  python3Packages,
  wrapGAppsHook3,
  yelp-tools,
}:

let
  inherit (python3Packages) python pygobject3;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gnumeric";
  version = "1.12.61";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gnumeric";
    tag = "GNUMERIC_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-SrAFYLCYacTobOmb+Jk4f4OWVLcWS8aq8OBFrdwYcbE=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    substituteInPlace configure.ac \
      --replace-fail 'GLIB_COMPILE_RESOURCES=' 'GLIB_COMPILE_RESOURCES="glib-compile-resources"#'
  '';

  nativeBuildInputs = [
    autoreconfHook
    gettext
    gtk-doc
    yelp-tools
    pkg-config
    intltool
    bison
    itstool
    glib # glib-compile-resources
    libxml2 # xmllint
    python.pythonOnBuildForHost
    wrapGAppsHook3
  ];

  # ToDo: optional libgda, introspection?
  # TODO: fix Perl plugin when cross-compiling
  buildInputs = [
    goffice
    gtk3
    adwaita-icon-theme
    python
    pygobject3
  ]
  ++ (with perlPackages; [
    perl
    XMLParser
  ]);

  configureFlags = [ "--disable-component" ];

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnumeric";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "GNOME Office Spreadsheet";
    homepage = "http://projects.gnome.org/gnumeric/";
    changelog = "https://gitlab.gnome.org/GNOME/gnumeric/-/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.vcunat ];
    platforms = lib.platforms.unix;
  };
})
