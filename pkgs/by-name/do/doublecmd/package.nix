{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  fpc,
  getopt,
  glib,
  lazarus,
  libsForQt5,
  libx11,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "doublecmd";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "doublecmd";
    repo = "doublecmd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VmiL3B4BmbKhk0eWmlKuPuPv6OsUk7DbFNoYGdcpeBM=";
  };

  postPatch = ''
    patchShebangs build.sh install/linux/install.sh
    substituteInPlace build.sh \
      --replace-warn '$(which lazbuild)' '"${lazarus}/bin/lazbuild --lazarusdir=${lazarus}/share/lazarus"'
    substituteInPlace install/linux/install.sh \
      --replace-warn '$DC_INSTALL_PREFIX/usr' '$DC_INSTALL_PREFIX'
  '';

  nativeBuildInputs = [
    fpc
    getopt
    lazarus
    libsForQt5.wrapQtAppsHook
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    dbus
    glib
    libx11
    libsForQt5.libqtpas
  ];

  env.NIX_LDFLAGS = "--as-needed -rpath ${lib.makeLibraryPath finalAttrs.buildInputs}";

  buildPhase = ''
    runHook preBuild

    ./build.sh release qt5

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install/linux/install.sh -I $out

    runHook postInstall
  '';

  meta = {
    description = "Two-panel graphical file manager written in Pascal";
    homepage = "https://doublecmd.sourceforge.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "doublecmd";
  };
})
# TODO: deal with other platforms too
