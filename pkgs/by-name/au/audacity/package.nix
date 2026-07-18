{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  at-spi2-core,
  cmake,
  dbus,
  expat,
  ffmpeg_8,
  file,
  flac,
  gettext,
  gtk3,
  lame,
  libepoxy,
  libid3tag,
  libjack2,
  libjpeg,
  libmad,
  libopus,
  libpng,
  libpthread-stubs,
  libsbsms_2_3_0,
  libselinux,
  libsepol,
  libsndfile,
  libuuid,
  libvorbis,
  libxdmcp,
  libxkbcommon,
  libxtst,
  lilv,
  linuxHeaders,
  lv2,
  makeWrapper,
  mpg123,
  opusfile,
  pkg-config,
  portaudio, # given up fighting their portaudio.patch?
  portmidi,
  python3,
  rapidjson,
  serd,
  sord,
  soundtouch,
  soxr,
  sqlite,
  sratom,
  suil,
  twolame,
  util-linux,
  wavpack,
  wrapGAppsHook3,
  wxwidgets_3_2,
}:

# TODO
# 1. detach sbsms

let
  ffmpeg = ffmpeg_8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "audacity";
  version = "3.7.8";

  src = fetchFromGitHub {
    owner = "audacity";
    repo = "audacity";
    rev = "Audacity-${finalAttrs.version}";
    hash = "sha256-Vp3Nx3LuNu5fqeLF6dvZ9/hhkoUCu0eCAdIEDtS1IwU=";
  };

  patches = [
    # Introduced by https://github.com/Tencent/rapidjson/commit/b1c0c2843fcb2aca9ecc650fc035c57ffc13697c#diff-2f1bcf2729ff7c408adb0c2cc2cfa01602bd5646b05b3e4bc7e46b606035d249R21
    ./rapidjson.patch
  ];

  postPatch = ''
    mkdir src/private
    substituteInPlace scripts/build/macOS/fix_bundle.py \
      --replace-fail "path.startswith('/usr/lib/')" "path.startswith('/usr/lib/') or path.startswith('${builtins.storeDir}')"
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace libraries/lib-files/FileNames.cpp \
      --replace-fail /usr/include/linux/magic.h ${linuxHeaders}/include/linux/magic.h
  '';

  nativeBuildInputs = [
    cmake
    gettext
    pkg-config
    python3
    makeWrapper
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    linuxHeaders
  ];

  buildInputs = [
    expat
    ffmpeg
    file
    flac
    gtk3
    lame
    libid3tag
    libjack2
    libmad
    libopus
    libsbsms_2_3_0
    libsndfile
    libvorbis
    lilv
    lv2
    mpg123
    opusfile
    portmidi
    rapidjson
    serd
    sord
    soundtouch
    soxr
    sqlite
    sratom
    suil
    twolame
    portaudio
    wavpack
    wxwidgets_3_2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib # for portaudio
    at-spi2-core
    dbus
    libepoxy
    libxdmcp
    libxtst
    libpthread-stubs
    libxkbcommon
    libselinux
    libsepol
    libuuid
    util-linux
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libpng
    libjpeg
  ];

  cmakeFlags = [
    "-DAUDACITY_BUILD_LEVEL=2"
    "-DAUDACITY_REV_LONG=nixpkgs"
    "-DAUDACITY_REV_TIME=nixpkgs"
    "-DDISABLE_DYNAMIC_LOADING_FFMPEG=ON"
    "-Daudacity_conan_enabled=Off"
    "-Daudacity_use_ffmpeg=loaded"
    "-Daudacity_has_vst3=Off"
    "-Daudacity_has_crashreports=Off"

    # RPATH of binary /nix/store/.../bin/... contains a forbidden reference to /build/
    "-DCMAKE_SKIP_BUILD_RPATH=ON"

    # Fix duplicate store paths
    "-DCMAKE_INSTALL_LIBDIR=lib"
  ];

  # [ 57%] Generating LightThemeAsCeeCode.h...
  # ../../utils/image-compiler: error while loading shared libraries:
  # lib-theme.so: cannot open shared object file: No such file or directory
  preBuild = ''
    export LD_LIBRARY_PATH=$PWD/Release/lib/audacity
  '';

  doCheck = false; # Test fails

  # Replace audacity's wrapper, to:
  # - Put it in the right place; it shouldn't be in "$out/audacity"
  # - Add the ffmpeg dynamic dependency
  # - Use Xwayland by default on Wayland. See https://github.com/audacity/audacity/pull/5977
  postFixup =
    lib.optionalString stdenv.hostPlatform.isLinux ''
      wrapProgram "$out/bin/audacity" \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : "$out/lib/audacity":${lib.makeLibraryPath [ ffmpeg ]} \
        --suffix AUDACITY_MODULES_PATH : "$out/lib/audacity/modules" \
        --suffix AUDACITY_PATH : "$out/share/audacity" \
        --set-default GDK_BACKEND x11
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/{Applications,bin}
      mv $out/Audacity.app $out/Applications/
      makeWrapper $out/Applications/Audacity.app/Contents/MacOS/Audacity $out/bin/audacity
    '';

  dontWrapGApps = true;

  meta = {
    description = "Sound editor with graphical UI";
    homepage = "https://www.audacityteam.org";
    changelog = "https://github.com/audacity/audacity/releases";

    license = with lib.licenses; [
      gpl2Plus
      # Must be GPL3 when building with "technologies that require it,
      # such as the VST3 audio plugin interface".
      # https://github.com/audacity/audacity/discussions/2142.
      gpl3
      # Documentation.
      cc-by-30
    ];

    maintainers = with lib.maintainers; [
      veprbl
      wegank
    ];

    platforms = lib.platforms.unix;
    mainProgram = "audacity";
  };
})
