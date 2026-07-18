{
  lib,
  stdenv,
  fetchurl,
  alure,
  boost,
  cmake,
  curl,
  doxygen,
  gettext,
  glib,
  gtk3,
  jsoncpp,
  libnotify,
  libpng,
  libtorrent-rasterbar,
  libx11,
  makeWrapper,
  minizip,
  openal,
  pcre,
  pkg-config,
  spring,
  wxwidgets_3_2,
}:

stdenv.mkDerivation rec {
  pname = "springlobby";
  version = "0.273";

  src = fetchurl {
    url = "https://springlobby.springrts.com/dl/stable/springlobby-${version}.tar.bz2";
    sha256 = "sha256-XkU6i6ABCgw3H9vJu0xjHRO1BglueYM1LyJxcZdOrDk=";
  };

  patches = [
    ./revert_58b423e.patch # Allows springLobby to continue using system installed spring until #707 is fixed
    ./fix-certs.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    gettext
    doxygen
    makeWrapper
  ];

  buildInputs = [
    wxwidgets_3_2
    openal
    curl
    libtorrent-rasterbar
    pcre
    jsoncpp
    boost
    libpng
    libx11
    libnotify
    gtk3
    glib
    minizip
    alure
  ];

  postInstall = ''
    wrapProgram $out/bin/springlobby \
      --prefix PATH : "${spring}/bin" \
      --set SPRING_BUNDLE_DIR "${spring}/lib"
  '';

  meta = {
    description = "Cross-platform lobby client for the Spring RTS project";
    homepage = "https://springlobby.springrts.com";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      qknight
    ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
