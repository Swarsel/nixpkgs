{
  lib,
  stdenv,
  autoreconfHook,
  boost,
  cmark,
  docbook_xsl,
  fetchFromCodeberg,
  flac,
  fmt,
  gettext,
  gmp,
  gtest,
  libdvdread,
  libebml,
  libiconv,
  libmatroska,
  libogg,
  libvorbis,
  libxslt,
  nix-update-script,
  nlohmann_json,
  pkg-config,
  pugixml,
  qt6,
  rake,
  utf8cpp,
  zlib,
  withGUI ? true,
}:

let
  inherit (lib)
    enableFeature
    getDev
    getLib
    optionals
    optionalString
    ;

  phase = name: args: ''
    runHook pre${name}

    rake ${args}

    runHook post${name}
  '';

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mkvtoolnix";
  version = "100.0";

  src = fetchFromCodeberg {
    owner = "mbunkus";
    repo = "mkvtoolnix";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-85mL3/x7SoTgOxU/YCFh58vcGzHLG3qPbbG4MD5dB9o=";
  };

  postPatch = ''
    # autoupdate is not needed but it silences a ton of pointless warnings
    patchShebangs . > /dev/null
    autoupdate configure.ac ac/*.m4

    # fix unit tests with GUI disabled
    sed -i '5i$gtest_apps.delete("gui") if !$build_mkvtoolnix_gui' rake.d/gtest.rb
  '';

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    gettext
    gtest
    libxslt
    pkg-config
    rake
  ]
  ++ optionals withGUI [ qt6.wrapQtAppsHook ];

  # qtbase and qtmultimedia are needed without the GUI
  buildInputs = [
    boost
    flac
    fmt
    gmp
    libdvdread
    libebml
    libmatroska
    libogg
    libvorbis
    nlohmann_json
    pugixml
    qt6.qtbase
    qt6.qtmultimedia
    utf8cpp
    zlib
  ]
  ++ optionals withGUI [ cmark ]
  ++ optionals stdenv.hostPlatform.isLinux [ qt6.qtwayland ];

  configureFlags = [
    "--disable-debug"
    "--disable-precompiled-headers"
    "--disable-profiling"
    "--disable-update-check"
    "--enable-optimization"
    "--with-boost-libdir=${getLib boost}/lib"
    "--with-docbook-xsl-root=${docbook_xsl}/share/xml/docbook-xsl"
    "--with-gettext"
    "--with-extra-includes=${getDev utf8cpp}/include/utf8cpp"
    "--with-extra-libs=${getLib utf8cpp}/lib"
    (enableFeature withGUI "gui")
  ];

  buildPhase = phase "Build" "";
  doCheck = true;
  checkPhase = phase "Check" "tests:run_unit";
  installPhase = phase "Install" "install";

  postFixup = optionalString withGUI ''
    wrapQtApp $out/bin/mkvtoolnix-gui
  '';

  __structuredAttrs = true;
  dontWrapQtApps = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [ "--version-regex=release-(.*)" ];
    };
  };

  meta = {
    description = "Cross-platform tools for Matroska";
    homepage = "https://mkvtoolnix.download/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      rnhmjoj
    ];

    platforms = lib.platforms.unix;
    mainProgram = if withGUI then "mkvtoolnix-gui" else "mkvtoolnix";
  };
})
