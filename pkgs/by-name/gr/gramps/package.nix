{
  lib,
  stdenv,
  fetchFromGitHub,
  desktopToDarwinBundle,
  gettext,
  gexiv2,
  ghostscript,
  glib-networking,
  glibcLocales,
  gobject-introspection,
  graphviz,
  gtk3,
  intltool,
  osm-gps-map,
  pango,
  python3Packages,
  wrapGAppsHook3,
  enableGhostscript ? true,
  enableGraphviz ? true,
  # Optional packages:
  enableOSM ? true,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "gramps";
  version = "6.0.6";

  src = fetchFromGitHub {
    owner = "gramps-project";
    repo = "gramps";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+sWO+c7haKXH42JVT6Zpz70cHdGC/TPgBUMSD+0+/JI=";
  };

  patches = [
    # textdomain doesn't exist as a property on locale when running on Darwin
    ./check-locale-hasattr-textdomain.patch
    # disables the startup warning about bad GTK installation
    ./disable-gtk-warning-dialog.patch
  ];

  # https://github.com/NixOS/nixpkgs/issues/149812
  # https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-hooks-gobject-introspection
  strictDeps = false;

  nativeBuildInputs = [
    wrapGAppsHook3
    intltool
    gettext
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    pango
    gexiv2
  ]
  # Map support
  ++ lib.optionals enableOSM [
    osm-gps-map
    glib-networking
  ]
  # Graphviz support
  ++ lib.optional enableGraphviz graphviz
  # Ghostscript support
  ++ lib.optional enableGhostscript ghostscript;

  nativeCheckInputs = [
    glibcLocales
    python3Packages.unittestCheckHook
    python3Packages.jsonschema
    python3Packages.mock
    python3Packages.lxml
  ]
  # TODO: use JHBuild to build the Gramps' bundle
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    mkdir .git # Make gramps think that it's not in an installed state
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
    )
  '';

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    berkeleydb
    orjson
    pyicu
    pygobject3
    pycairo
  ];

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Genealogy software";

    longDescription = ''
      Every person has their own story but they are also part of a collective
      family history. Gramps gives you the ability to record the many details of
      an individual's life as well as the complex relationships between various
      people, places and events. All of your research is kept organized,
      searchable and as precise as you need it to be.
    '';

    homepage = "https://gramps-project.org";
    changelog = "https://github.com/gramps-project/gramps/blob/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      jk
      pinpox
      tomasajt
    ];

    mainProgram = "gramps";
  };
})
