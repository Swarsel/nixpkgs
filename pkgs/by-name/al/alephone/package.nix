{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  SDL2_image,
  SDL2_net,
  SDL2_ttf,
  alsa-lib,
  asio,
  boost,
  curl,
  ffmpeg_6,
  icoutils,
  libGLU,
  libmad,
  libogg,
  libpng,
  libsndfile,
  libvorbis,
  lua,
  makeDesktopItem,
  makeWrapper,
  miniupnpc,
  openal,
  pkg-config,
  speex,
  testers,
  unzip,
  zlib,
  zziplib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alephone";
  version = "1.11";

  src = fetchurl {
    url =
      let
        date = "20250829";
      in
      "https://github.com/Aleph-One-Marathon/alephone/releases/download/release-${date}/AlephOne-${date}.tar.bz2";

    hash = "sha256-58RHA0qjXdhcpoNt2DZwNMT0USqg0U6XgdcDOUYJiAY=";
  };

  outputs = [
    "out"
    "icons"
  ];

  nativeBuildInputs = [
    pkg-config
    icoutils
  ];

  buildInputs = [
    alsa-lib
    boost
    curl
    ffmpeg_6
    libGLU
    libmad
    libogg
    libpng
    libsndfile
    libvorbis
    lua
    miniupnpc
    openal
    SDL2
    SDL2_image
    SDL2_net
    SDL2_ttf
    speex
    zlib
    zziplib
    asio
  ];

  configureFlags = [ "--with-boost-libdir=${boost.out}/lib" ];
  makeFlags = [ "AR:=$(AR)" ];

  postInstall = ''
    mkdir $icons
    icotool -x -i 5 -o $icons Resources/Windows/*.ico
    pushd $icons
    for x in *_5_48x48x32.png; do
      mv $x ''${x%_5_48x48x32.png}.png
    done
    popd
  '';

  enableParallelBuilding = true;

  passthru.makeWrapper =
    {
      desktopName,
      meta,
      version,
      zip,
      icon ? finalAttrs.finalPackage.icons + "/alephone.png",
      ...
    }@extraArgs:
    stdenv.mkDerivation (
      {
        inherit version;
        src = zip;

        nativeBuildInputs = [
          makeWrapper
          unzip
        ];

        installPhase = ''
          mkdir -p $out/bin $out/data/alephone $out/share/applications
          cp -a * $out/data/alephone
          cp $desktopItem/share/applications/* $out/share/applications
          makeWrapper ${finalAttrs.finalPackage}/bin/alephone $out/bin/alephone \
            --add-flags $out/data/alephone
        '';

        desktopItem = makeDesktopItem {
          inherit desktopName icon;
          categories = [ "Game" ];
          comment = meta.description;
          exec = "alephone";
          genericName = "alephone";
          name = desktopName;
        };

        dontBuild = true;
        dontConfigure = true;
      }
      // extraArgs
      // {
        meta =
          finalAttrs.finalPackage.meta
          // {
            license = lib.licenses.free;
            mainProgram = "alephone";
            hydraPlatforms = [ ];
          }
          // meta;
      }
    );

  passthru.tests.version =
    # test that the version is correct
    testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Aleph One is the open source continuation of Bungie’s Marathon 2 game engine";
    homepage = "https://alephone.lhowon.org/";
    license = [ lib.licenses.gpl3 ];
    platforms = lib.platforms.linux;
    mainProgram = "alephone";
  };
})
