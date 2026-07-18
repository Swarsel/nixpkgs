{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  boost,
  catch2_3,
  cmake,
  cpp-jwt,
  cryptopp,
  cubeb,
  darwinMinVersionHook,
  doxygen,
  dynarmic,
  enet,
  fetchpatch,
  ffmpeg_6-headless,
  fmt,
  gamemode,
  glslang,
  gsettings-desktop-schemas,
  gtk3,
  httplib,
  inih,
  libGL,
  libunwind,
  libusb1,
  libx11,
  libxcb,
  libxext,
  moltenvk,
  nix-update-script,
  nlohmann_json,
  oaknut,
  openal,
  openssl,
  pipewire,
  pkg-config,
  portaudio,
  python3,
  qt6,
  rapidjson,
  robin-map,
  soundtouch,
  vulkan-headers,
  vulkan-memory-allocator,
  xbyak,
  enableCubeb ? true,
  enableGamemode ? lib.meta.availableOn stdenv.hostPlatform gamemode,
  enableQtTranslations ? true,
  enableSSE42 ? true, # Disable if your hardware doesn't support SSE 4.2 (mainly CPUs before 2011)
  useDiscordRichPresence ? true,
}:
let
  inherit (lib)
    optionals
    optionalString
    cmakeBool
    getLib
    ;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "azahar";
  version = "2125.1.3";

  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "azahar";
    tag = finalAttrs.version;
    hash = "sha256-jn5Ib5jM/6zHuCjWoMkTvs0nR29mAbTlvID5aYZLw5o=";

    postCheckout = ''
      git -C "$out/externals" submodule update --init \
        teakra zstd discord-rpc spirv-headers spirv-tools sirit xxHash \
        faad2/faad2 lodepng/lodepng dds-ktx nihstro "$out/dist/compatibility_list"
      echo "${finalAttrs.version}" > "$out/GIT-TAG"
      git -C "$out" rev-parse HEAD > "$out/GIT-COMMIT"
    '';
  };

  postPatch = ''
    # We already know the submodules are present
    substituteInPlace CMakeLists.txt \
      --replace-fail "check_submodules_present()" ""
  ''
  # Add gamemode
  + optionalString enableGamemode ''
    substituteInPlace externals/gamemode/include/gamemode_client.h \
      --replace-fail "libgamemode.so.0" "${getLib gamemode}/lib/libgamemode.so.0"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    doxygen
    python3
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    catch2_3
    cryptopp
    cpp-jwt
    dynarmic
    enet
    fmt
    ffmpeg_6-headless
    glslang
    httplib
    inih
    libGL
    libunwind
    libusb1
    nlohmann_json
    openal
    openssl
    portaudio
    robin-map
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qttools
    soundtouch
    SDL2
    vulkan-headers
    vulkan-memory-allocator

    # https://github.com/azahar-emu/azahar/issues/1283
    # spirv-tools
    # spirv-headers

    # Azahar uses zstd_seekable which is not currently packaged in nixpkgs
    # zstd
  ]
  ++ optionals stdenv.hostPlatform.isx86_64 [ xbyak ]
  ++ optionals stdenv.hostPlatform.isAarch64 [ oaknut ]
  ++ optionals enableQtTranslations [ qt6.qttools ]
  ++ optionals enableCubeb [ cubeb ]
  ++ optionals useDiscordRichPresence [ rapidjson ]
  ++ optionals stdenv.hostPlatform.isLinux [
    pipewire
    qt6.qtwayland
    libx11
    libxcb
    libxext
  ]
  ++ optionals stdenv.hostPlatform.isDarwin [
    moltenvk
    (darwinMinVersionHook "13.4")
  ];

  cmakeFlags = [
    (cmakeBool "USE_SYSTEM_LIBS" true)
    (cmakeBool "DISABLE_SYSTEM_LODEPNG" true)
    (cmakeBool "DISABLE_SYSTEM_VMA" true)
    (cmakeBool "DISABLE_SYSTEM_ZSTD" true)
    (cmakeBool "DISABLE_SYSTEM_SPIRV_HEADERS" true)
    (cmakeBool "ENABLE_QT_TRANSLATION" enableQtTranslations)
    (cmakeBool "ENABLE_CUBEB" enableCubeb)
    (cmakeBool "USE_DISCORD_PRESENCE" useDiscordRichPresence)
    (cmakeBool "ENABLE_SSE42" enableSSE42)
  ];

  installPhase = optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin

    cp ./bin/Release/${finalAttrs.pname}-room $out/bin
    cp -r ./bin/Release/${finalAttrs.pname}.app $out/Applications

    runHook postInstall
  '';

  preFixup = ''
    qtWrapperArgs+=(
      --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
      ${optionalString stdenv.hostPlatform.isDarwin "--prefix DYLD_LIBRARY_PATH : ${
        lib.makeLibraryPath [ moltenvk ]
      }"}
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source 3DS emulator project based on Citra";
    homepage = "https://github.com/azahar-emu/azahar";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ marcin-serwin ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "azahar";
  };
})
