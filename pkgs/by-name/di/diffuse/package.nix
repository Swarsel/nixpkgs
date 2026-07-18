{
  lib,
  fetchFromGitHub,
  atk,
  gdk-pixbuf,
  gettext,
  gitUpdater,
  gobject-introspection,
  gtk3,
  hicolor-icon-theme,
  meson,
  ninja,
  pango,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "diffuse";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "MightyCreak";
    repo = "diffuse";
    rev = "v${finalAttrs.version}";
    sha256 = "vQVtvQrs8oPevvrC75T2YcdYuT5XYDiAFDTduTkICBk=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    meson
    ninja
    gettext
    gobject-introspection
  ];

  buildInputs = [
    pango
    gdk-pixbuf
    atk
    gtk3
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pycairo
    pygobject3
  ];

  mesonFlags = [
    "-Db_ndebug=true"
  ];

  # to avoid running gtk-update-icon-cache, update-desktop-database and glib-compile-schemas
  env.DESTDIR = "/";

  preConfigure = ''
    # app bundle for macos
    substituteInPlace src/diffuse/meson.build data/icons/meson.build src/diffuse/mac-os-app/diffuse-mac.in --replace-fail "/Applications" "$out/Applications";
  '';

  makeWrapperArgs = [
    "--prefix XDG_DATA_DIRS : ${hicolor-icon-theme}/share"
  ];

  pyproject = false;

  passthru = {
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    description = "Graphical tool for merging and comparing text files";
    homepage = "https://github.com/MightyCreak/diffuse";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ k3a ];
    platforms = lib.platforms.unix;
    mainProgram = "diffuse";
  };
})
