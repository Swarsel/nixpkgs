{
  lib,
  stdenv,
  fetchFromGitHub,
  aalib,
  alsa-lib,
  aribb24,
  autoPatchelfHook,
  boost,
  chromaprint,
  cups,
  faad2,
  fetchpatch,
  ffmpeg,
  ffmpeg_6,
  file,
  flac,
  fontconfig,
  glib,
  gnupg,
  gradle,
  gtk3,
  jetbrains, # Required by upstream due to JCEF dependency
  lcms2,
  libGL,
  libarchive,
  libavc1394,
  libbluray,
  libcaca,
  libcddb,
  libdc1394,
  libdvbpsi,
  libdvdnav,
  libdvdread,
  libebml,
  libgcrypt,
  libidn,
  libjpeg8,
  libkate,
  libmad,
  libmatroska,
  libmpcdec,
  libmpeg2,
  libmtp,
  libnfs,
  libnotify,
  libogg,
  libopenmpt-modplug,
  librsvg,
  libsamplerate,
  libsecret,
  libshout,
  libsidplayfp,
  libspatialaudio,
  libupnp,
  libva,
  libvlc,
  libvncserver,
  libvorbis,
  libx11,
  libxcb-keysyms,
  libxdamage,
  libxinerama,
  libxml2,
  libxpm,
  libxrandr,
  lirc,
  lua5_2,
  nix-update,
  nspr,
  nss,
  protobuf_21,
  pulseaudio,
  qt5,
  samba,
  shine,
  sox,
  speexdsp,
  srt,
  taglib,
  taglib_1,
  thrift,
  twolame,
  writeShellScript,
  zvbi,
}:
let
  thrift20 = thrift.overrideAttrs (old: {
    version = "0.20.0";

    src = fetchFromGitHub {
      owner = "apache";
      repo = "thrift";
      tag = "v0.20.0";
      hash = "sha256-cwFTcaNHq8/JJcQxWSelwAGOLvZHoMmjGV3HBumgcWo=";
    };

    patches = (old.patches or [ ]) ++ [
      # Fix build with gcc15
      # https://github.com/apache/thrift/pull/3078
      (fetchpatch {
        hash = "sha256-pWcG6/BepUwc/K6cBs+6d74AWIhZ2/wXvCunb/KyB0s=";
        name = "thrift-add-missing-cstdint-include-gcc15.patch";
        url = "https://github.com/apache/thrift/commit/947ad66940cfbadd9b24ba31d892dfc1142dd330.patch";
      })
    ];

    cmakeFlags = (old.cmakeFlags or [ ]) ++ [
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.10"
    ];
  });

in
stdenv.mkDerivation (finalAttrs: {
  pname = "animeko";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "open-ani";
    repo = "animeko";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mDUl1RpTIFBHdYst6R16iVljiUNOYh6mNUtOLBSuOE0=";
    fetchSubmodules = true;
  };

  patches = [
    # Builtin updater will never work on NixOS, so we made a patch to disable updater
    ./0001-no-update-checker.patch
  ];

  postPatch = ''
    echo "kotlin.native.ignoreDisabledTargets=true" >> local.properties
    sed -i "s/^version.name=.*/version.name=${finalAttrs.version}/" gradle.properties
    sed -i "s/^package.version=.*/package.version=${finalAttrs.version}/" gradle.properties
  '';

  nativeBuildInputs = [
    gradle
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    libxinerama
    libxrandr
    file
    shine
    libmpeg2
    gtk3
    glib
    cups
    lcms2
    alsa-lib
    libidn
    pulseaudio
    ffmpeg
    faad2
    libjpeg8
    libkate
    librsvg
    libxpm
    qt5.qtsvg
    qt5.qtbase
    qt5.qtx11extras
    libupnp
    aalib
    libcaca
    libva
    libdvbpsi
    libogg
    chromaprint
    protobuf_21
    libgcrypt
    libsecret
    aribb24
    twolame
    libmpcdec
    libvorbis
    libebml
    libmatroska
    libopenmpt-modplug
    libavc1394
    libmtp
    libsidplayfp
    libarchive
    gnupg
    srt
    libshout
    ffmpeg_6
    libxcb-keysyms
    lirc
    lua5_2
    taglib
    libspatialaudio
    speexdsp
    libsamplerate
    sox
    libmad
    libnotify
    zvbi
    libdc1394
    libcddb
    libbluray
    libdvdread
    libvncserver
    samba
    libnfs
    taglib_1
    libdvdnav
    flac
    libxml2
    boost
    thrift20
    nss
    nspr
    libGL
    libx11
    libxdamage
  ];

  env = {
    ANDROID_SDK_HOME = "$(pwd)";
    JAVA_HOME = jetbrains.jdk-21;
  };

  doCheck = false;

  installPhase = ''
    runHook preInstall

    cp -r app/desktop/build/compose/binaries/main-release/app/Ani $out
    chmod +x $out/lib/runtime/lib/jcef_helper
    substituteInPlace app/desktop/appResources/linux-x64/animeko.desktop \
      --replace-fail "icon" "animeko"
    install -Dm644 app/desktop/appResources/linux-x64/animeko.desktop $out/share/applications/animeko.desktop
    install -Dm644 app/desktop/appResources/linux-x64/icon.png $out/share/icons/hicolor/512x512/apps/animeko.png

    runHook postInstall
  '';

  preFixup = ''
    # Remove prebuilt vlc and use NixOS version
    rm -r $out/lib/app/resources/lib
    ln -sf ${libvlc}/lib $out/lib/app/resources/
  '';

  dontWrapQtApps = true;
  gradleBuildTask = "createReleaseDistributable";

  gradleFlags = [
    "-Dorg.gradle.java.home=${jetbrains.jdk-21}"
  ];

  gradleUpdateTask = finalAttrs.gradleBuildTask;

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
    pkg = finalAttrs.finalPackage;
    silent = false;
    useBwrap = false;
  };

  passthru.updateScript = writeShellScript "update-animeko" ''
    ${lib.getExe nix-update} animeko
    $(nix-build -A animeko.mitmCache.updateScript)
  '';

  meta = {
    description = "One-stop platform for finding, following and watching anime";
    homepage = "https://github.com/open-ani/animeko";
    license = lib.licenses.agpl3Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [
      pokon548
    ];

    platforms = [
      "x86_64-linux"
    ];

    mainProgram = "Ani";
    # Mark broken due to a breaking change in JetBrains JCEF
    # https://github.com/NixOS/nixpkgs/pull/485812#issuecomment-4211365591
    broken = true;
  };
})
