{
  lib,
  stdenv,
  alsa-lib,
  callPackage,
  cmake,
  deno,
  expat,
  ffmpeg,
  fribidi,
  game-music-emu,
  libass,
  libcddb,
  libcdio,
  libmpg123,
  libogg,
  libopenmpt,
  libpulseaudio,
  libsidplayfp,
  libsysprof-capture,
  libva,
  libvorbis,
  libxcb,
  libxdmcp,
  libxv,
  ninja,
  pipewire,
  pkg-config,
  qt5,
  qt6,
  rubberband,
  shaderc,
  taglib,
  vulkan-headers,
  vulkan-tools,
  # Configurable options
  qtVersion ? "6", # Can be 5 or 6
}:

let
  sources = callPackage ./sources.nix { };
  vulkan-headers-qmplay2 = vulkan-headers.overrideAttrs (oldAttrs: {
    inherit (sources.vulkan-headers-qmplay2) version src;
  });
in
assert lib.elem qtVersion [
  "5"
  "6"
];
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.qmplay2) version src;
  pname = sources.qmplay2.pname + "-qt" + qtVersion;

  postPatch = ''
    pushd src
    cp -va ${sources.qmvk.src}/* qmvk/
    chmod --recursive 744 qmvk
    popd
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    shaderc
  ]
  ++ lib.optionals (qtVersion == "6") [ qt6.wrapQtAppsHook ]
  ++ lib.optionals (qtVersion == "5") [ qt5.wrapQtAppsHook ];

  buildInputs = [
    alsa-lib
    ffmpeg
    fribidi
    game-music-emu
    libxdmcp
    libxv
    libass
    libcddb
    libcdio
    libpulseaudio
    libsidplayfp
    libva
    libxcb
    taglib
    vulkan-headers-qmplay2
    vulkan-tools
    deno
    expat
    libmpg123
    libogg
    libopenmpt
    libsysprof-capture
    libvorbis
    pipewire
  ]
  ++ lib.optionals (qtVersion == "6") [
    rubberband
    qt6.qt5compat
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
  ]
  ++ lib.optionals (qtVersion == "5") [
    qt5.qtbase
    qt5.qttools
  ];

  cmakeFlags = lib.optionals (qtVersion == "5") [
    (lib.cmakeBool "BUILD_WITH_QT6" false)
  ];

  # Because we think it is better to use only lowercase letters!
  # But sometimes we come across case-insensitive filesystems...
  postInstall = ''
    [ -e $out/bin/qmplay2 ] || ln -s $out/bin/QMPlay2 $out/bin/qmplay2

    wrapQtApp $out/bin/qmplay2 \
      --prefix PATH : ${lib.makeBinPath [ deno ]}
  '';

  passthru = {
    inherit sources;
  };

  meta = {
    description = "Qt-based Multimedia player";

    longDescription = ''
      QMPlay2 is a video and audio player. It can play all formats supported by
      FFmpeg and libmodplug (including J2B and SFX). It also supports Audio CD,
      raw files, Rayman 2 music, and chiptunes. It also contains YouTube and
      MyFreeMP3 browser.
    '';

    homepage = "https://github.com/zaps166/QMPlay2/";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      kashw2
      ProxyVT
    ];

    platforms = lib.platforms.linux;
    mainProgram = "qmplay2";
  };
})
