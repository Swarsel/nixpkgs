{
  lib,
  stdenv,
  fetchurl,
  bc,
  file,
  hunspell,
  libsForQt5,
  makeWrapper, # , mythes, boost
  pkg-config,
  python3,
}:

stdenv.mkDerivation rec {
  pname = "lyx";
  version = "2.5.1";

  src = fetchurl {
    url = "ftp://ftp.lyx.org/pub/lyx/stable/2.5.x/lyx-${version}.tar.xz";
    hash = "sha256-8qI4e8s/L1RsH8E+THTLT4qmSHBs5XiO9wXdUTRNLP0=";
  };

  # LaTeX is used from $PATH, as people often want to have it with extra pkgs
  nativeBuildInputs = [
    pkg-config
    makeWrapper
    python3
    libsForQt5.qtbase
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtsvg
    file # for libmagic
    bc
    hunspell # enchant
  ];

  configureFlags = [
    "--enable-qt5"
    #"--without-included-boost"
    /*
      Boost is a huge dependency from which 1.4 MB of libs would be used.
       Using internal boost stuff only increases executable by around 0.2 MB.
    */
    #"--without-included-mythes" # such a small library isn't worth a separate package
  ];

  doCheck = true;
  enableParallelBuilding = true;
  # python is run during runtime to do various tasks
  qtWrapperArgs = [ " --prefix PATH : ${python3}/bin" ];

  meta = {
    description = "WYSIWYM frontend for LaTeX, DocBook";
    homepage = "https://www.lyx.org";
    changelog = "https://www.lyx.org/announce/${lib.replaceString "." "_" version}.txt";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.vcunat ];
    platforms = lib.platforms.linux;
  };
}
