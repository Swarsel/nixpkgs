{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  copyDesktopItems,
  flac,
  glslang,
  gzip,
  libmpg123,
  libopus,
  libvorbis,
  libx11,
  makeDesktopItem,
  makeWrapper,
  meson,
  moltenvk,
  ninja,
  opusfile,
  pkg-config,
  spirv-tools,
  vulkan-headers,
  vulkan-loader,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vkquake";
  version = "1.34.1";

  src = fetchFromGitHub {
    owner = "Novum";
    repo = "vkQuake";
    tag = finalAttrs.version;
    hash = "sha256-vCjL8zDf+VJjYHQoXPY9kqrAiU7HA7avJcOx6v2Jujg=";
  };

  nativeBuildInputs = [
    makeWrapper
    glslang
    spirv-tools
    meson
    ninja
    pkg-config
    copyDesktopItems
  ];

  buildInputs = [
    SDL2
    flac
    gzip
    libmpg123
    libopus
    libvorbis
    libx11
    opusfile
    vulkan-loader
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    moltenvk
    vulkan-headers
  ];

  mesonFlags = [ "-Ddo_userdirs=enabled" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_COMPILE = lib.concatStringsSep " " [
      "-Wno-error=unused-but-set-variable"
      "-Wno-error=implicit-const-int-float-conversion"
    ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp vkquake "$out/bin"

    install -D ../Misc/vkQuake_256.png "$out/share/icons/hicolor/256x256/apps/vkquake.png"

    runHook postInstall
  '';

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    patchelf $out/bin/vkquake \
      --add-rpath ${lib.makeLibraryPath [ vulkan-loader ]}
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = finalAttrs.meta.description;
      desktopName = "vkQuake";
      exec = finalAttrs.meta.mainProgram;
      icon = "vkquake";
      name = "vkquake";
    })
  ];

  meta = {
    description = "Vulkan Quake port based on QuakeSpasm";

    longDescription = ''
      vkQuake is a Quake 1 port using Vulkan instead of OpenGL for rendering.
      It is based on the popular QuakeSpasm port and runs all mods compatible with it
      like Arcane Dimensions or In The Shadows. vkQuake also serves as a Vulkan demo
      application that shows basic usage of the API. For example it demonstrates render
      passes & sub passes, pipeline barriers & synchronization, compute shaders, push &
      specialization constants, CPU/GPU parallelism and memory pooling.
    '';

    homepage = "https://github.com/Novum/vkQuake";
    changelog = "https://github.com/Novum/vkQuake/releases";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      PopeRigby
      ylh
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "vkquake";
  };
})
