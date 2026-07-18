{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  hicolor-icon-theme,
  imagemagick,
  libappindicator-gtk3,
  librsvg,
  libwnck,
  perlPackages,
  procps,
  wrapGAppsHook3,
  xdg-utils,
}:

let
  perlModules = with perlPackages; [
    Cairo
    CairoGObject
    CarpAlways
    commonsense
    EncodeLocale
    FileBaseDir
    FileCopyRecursive
    FileWhich
    Glib
    GlibObjectIntrospection
    GooCanvas2
    GooCanvas2CairoTypes
    Gtk3
    Gtk3ImageView
    HTMLForm
    HTMLParser
    HTMLTagset
    HTTPCookies
    HTTPDate
    HTTPMessage
    ImageExifTool
    ImageMagick
    JSON
    JSONMaybeXS
    LocaleGettext
    LWP
    LWPProtocolHttps
    Moo
    NetDBus
    NumberBytesHuman
    Pango
    PathClass
    ProcProcessTable
    ProcSimple
    Readonly
    SortNaturally
    SubQuote
    TryTiny
    TypesSerialiser
    URI
    X11Protocol
    XMLParser
    XMLSimple
    XMLTwig
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "shutter";
  version = "0.99.7";

  src = fetchFromGitHub {
    owner = "shutter-project";
    repo = "shutter";
    tag = finalAttrs.version;
    sha256 = "sha256-iri4yj2DujsEfpa6u4f5bpaOhWL0h/XbSlolkSJgKgE=";
  };

  postPatch = ''
    patchShebangs po2mo.sh
  '';

  nativeBuildInputs = [ wrapGAppsHook3 ];

  buildInputs = [
    perlPackages.perl
    procps
    gdk-pixbuf
    librsvg
    libwnck
    libappindicator-gtk3
    hicolor-icon-theme
  ]
  ++ perlModules;

  makeFlags = [
    "prefix=${placeholder "out"}"
  ];

  preFixup = ''
    # make xdg-open overrideable at runtime
    gappsWrapperArgs+=(
      --set PERL5LIB ${perlPackages.makePerlPath perlModules} \
      --prefix PATH : ${lib.makeBinPath [ imagemagick ]}
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
    )
  '';

  __structuredAttrs = true;

  meta = {
    description = "Screenshot and annotation tool";
    homepage = "https://shutter-project.org/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.all;
    mainProgram = "shutter";
  };
})
