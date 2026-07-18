{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  fetchpatch,
  gdk-pixbuf,
  glib-networking,
  glibcLocales,
  gobject-introspection,
  gpsbabel,
  gtk3,
  perl,
  python3,
  sqlite,
  tzdata,
  webkitgtk_4_1,
  wrapGAppsHook3,
  xvfb-run,
}:

let
  python = python3.override {
    packageOverrides = (
      self: super: {
        matplotlib = super.matplotlib.override {
          enableGtk3 = true;
        };
      }
    );

    self = python;
  };
in
python.pkgs.buildPythonApplication (finalAttrs: {
  pname = "pytrainer";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "pytrainer";
    repo = "pytrainer";
    rev = "v${finalAttrs.version}";
    hash = "sha256-t61vHVTKN5KsjrgbhzljB7UZdRask7qfYISd+++QbV0=";
  };

  patches = [
    # Fix startup crash with SQLAlchemy 2.0
    (fetchpatch {
      hash = "sha256-cGNu4lK0eQWzcSFTKc8g/qHSSHfy0ow4T3eT+zl5lPM=";
      url = "https://github.com/pytrainer/pytrainer/commit/9847c76e61945466775bde038057bf5fd31ae089.patch";
    })

    # Port to webkigtk 4.1
    (fetchpatch {
      hash = "sha256-MdxsKO6DgncHhGlJWcEeyYiPKf3qdhMqXrYYC+jqros=";
      url = "https://github.com/pytrainer/pytrainer/commit/eda968a8b48074f03efbdfbd692b46edef3658cd.patch";
    })
  ];

  postPatch = ''
    substituteInPlace pytrainer/platform.py \
        --replace-fail 'sys.prefix' "\"$out\""
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    sqlite
    gtk3
    webkitgtk_4_1
    glib-networking
    adwaita-icon-theme
    gdk-pixbuf
  ];

  nativeCheckInputs = [
    glibcLocales
    perl
    xvfb-run
  ]
  ++ (with python.pkgs; [
    mysqlclient
    psycopg2
  ]);

  checkPhase = ''
    env \
      HOME=$TEMPDIR \
      TZDIR=${tzdata}/share/zoneinfo \
      TZ=Europe/Kaliningrad \
      LC_TIME=C \
      xvfb-run -s '-screen 0 800x600x24' \
      ${python.interpreter} -m unittest
  '';

  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python.pkgs; [
    sqlalchemy
    python-dateutil
    matplotlib
    lxml
    requests
    gdal
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      perl
      gpsbabel
    ])
  ];

  pyproject = true;

  meta = {
    description = "Application for logging and graphing sporting excursions";
    homepage = "https://github.com/pytrainer/pytrainer";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      rycee
      dotlambda
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pytrainer";
  };
})
