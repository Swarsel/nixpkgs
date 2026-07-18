{
  lib,
  stdenv,
  fetchFromGitLab,
  appstream,
  dblatex,
  desktop-file-utils,
  docbook-xsl-nons,
  docbook_xml_dtd_45,
  gdk-pixbuf,
  graphene,
  gtk-mac-integration-gtk3,
  gtk3,
  libxml2,
  libxslt,
  meson,
  ninja,
  pkg-config,
  poppler,
  python3,
  wrapGAppsHook3,
}:

let
  xpm-pixbuf = stdenv.mkDerivation {
    pname = "xpm-pixbuf";
    version = "0-unstable-2024-05-24";

    src = fetchFromGitLab {
      owner = "ZanderBrown";
      repo = "xpm-pixbuf";
      rev = "d290a0c846687b22d2a8c5aaec83a6689f30e1c3";
      hash = "sha256-LU6nKe7IIecF/3wwhlwR1hyABBvfwvujVW5zJJSzkqo=";
      domain = "gitlab.gnome.org";
    };

    nativeBuildInputs = [
      meson
      ninja
      pkg-config
    ];

    buildInputs = [ gdk-pixbuf ];

    meta = {
      homepage = "https://gitlab.gnome.org/ZanderBrown/xpm-pixbuf";
      license = lib.licenses.lgpl21;
    };
  };
in
stdenv.mkDerivation {
  pname = "dia";
  version = "unstable-2025-10-26";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "dia";
    rev = "efdf829e8afdbbeb371820932769e35415ebe886";
    hash = "sha256-VFFU5iJnVJdZ2tkNszZ2ooBD+GiCL6MqanzpEWIJerk=";
    domain = "gitlab.gnome.org";
  };

  postPatch = ''
    # Fix build with poppler 25.10.0
    substituteInPlace plug-ins/pdf/pdf-import.cpp \
      --replace-fail 's->getLength();' 's->size();'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    dblatex
    dblatex.tex
    desktop-file-utils
    docbook-xsl-nons
    docbook_xml_dtd_45
    libxml2 # xmllint
    libxslt
    meson
    ninja
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    graphene
    gtk3
    libxml2
    libxslt
    python3
    poppler
    xpm-pixbuf
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    gtk-mac-integration-gtk3
  ];

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/org.gnome.Dia.thumbnailer \
      --replace-fail "TryExec=dia" "TryExec=$out/bin/dia" \
      --replace-fail "Exec=dia" "Exec=$out/bin/dia"
  '';

  dontUseCmakeConfigure = true;

  meta = {
    description = "Gnome Diagram drawing software";
    homepage = "https://wiki.gnome.org/Apps/Dia";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "dia";
  };
}
