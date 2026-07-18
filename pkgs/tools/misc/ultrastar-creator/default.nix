{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cld2,
  libbass,
  libbass_fx,
  makeDesktopItem,
  pkg-config,
  pulseaudio,
  qt6,
  taglib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ultrastar-creator";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "UltraStar-Deluxe";
    repo = "UltraStar-Creator";
    tag = finalAttrs.version;
    hash = "sha256-QWlgMpyNadRh6Tkg1mAtb11mKbk4thE6sCQKiDyR/SA=";
  };

  postPatch = ''
    rm -rf lib include/bass include/bass_fx include/cld2

    echo 'const char *revision = "${finalAttrs.version}"; const char *date_time = "unknown";' \
      > src/version.h

    substituteInPlace src/UltraStar-Creator.pro \
      --replace-fail 'DESTDIR = ../bin/release' "DESTDIR = $out/bin" \
      --replace-fail 'DESTDIR = ../bin/debug'   "DESTDIR = $out/bin" \
      --replace-fail '../include/bass_fx'        '${lib.getLib libbass_fx}/include' \
      --replace-fail '../include/bass'           '${lib.getLib libbass}/include' \
      --replace-fail '../include/cld2/public'    '${cld2}/include/cld2/public' \
      --replace-fail '../include/taglib'         '${lib.getDev taglib}/include'

    sed -i \
      -e 's|-L"../lib/unix"||' \
      -e 's|-L"/usr/lib/x86_64-linux-gnu"||' \
      -e '/QMAKE_POST_LINK/d' \
      src/UltraStar-Creator.pro

    sed -i \
      -e '/QMAKE_EXTRA_TARGETS.*revtarget/d' \
      -e '/PRE_TARGETDEPS.*version\.h/d' \
      -e '/^revtarget\.target/d' \
      -e '/^\trevtarget\./d' \
      -e '/^revtarget\.depends/,/[^\\]$/d' \
      src/UltraStar-Creator.pro
  '';

  nativeBuildInputs = [
    pkg-config
    qt6.qmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    cld2
    libbass
    libbass_fx
    qt6.qtbase
    taglib
    alsa-lib
    pulseaudio
  ];

  preConfigure = ''
    cd src
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 ../setup/unix/UltraStar-Creator.png $out/share/icons/hicolor/128x128/apps/ultrastar-creator.png
    ln -s "$desktopItem/share/applications" "$out/share/"

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    desktopName = "UltraStar-Creator";
    exec = "UltraStar-Creator";
    icon = "ultrastar-creator";
    name = finalAttrs.pname;
  };

  qtWrapperArgs = [
    "--prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        alsa-lib
        pulseaudio
      ]
    }"
  ];

  meta = {
    description = "Ultrastar karaoke song creation tool";
    homepage = "https://github.com/UltraStar-Deluxe/UltraStar-Creator";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mooses ];
    platforms = lib.platforms.linux;
    mainProgram = "UltraStar-Creator";
  };
})
