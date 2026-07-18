{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cargo,
  cmake,
  curl,
  ffmpeg,
  freetype,
  glslang,
  gtest,
  libGLU,
  libnotify,
  libogg,
  libx11,
  ninja,
  opusfile,
  pkg-config,
  python3,
  rustPlatform,
  rustc,
  spirv-tools,
  sqlite,
  vulkan-headers,
  vulkan-loader,
  wavpack,
  x264,
  buildClient ? true,
}:

stdenv.mkDerivation rec {
  pname = "ddnet";
  version = "19.8.3";

  src = fetchFromGitHub {
    owner = "ddnet";
    repo = "ddnet";
    tag = version;
    hash = "sha256-/SfUDliB6fdc/yf2yVXHiqYlH+cIIoxz3RkP8SxsgA4=";
  };

  postPatch = ''
    substituteInPlace src/engine/shared/storage.cpp \
      --replace /usr/ $out/
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    rustc
    cargo
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    curl
    libnotify
    python3
    sqlite
  ]
  ++ lib.optionals buildClient (
    [
      freetype
      libGLU
      libogg
      opusfile
      SDL2
      wavpack
      ffmpeg
      x264
      vulkan-loader
      vulkan-headers
      glslang
      spirv-tools
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libx11
    ]
  );

  cmakeFlags = [
    "-DAUTOUPDATE=OFF"
    "-DCLIENT=${if buildClient then "ON" else "OFF"}"
  ];

  # Tests loop forever on Darwin for some reason
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    gtest
  ];

  postInstall = lib.optionalString (!buildClient) ''
    # DDNet's CMakeLists.txt automatically installs .desktop
    # shortcuts and icons for the client, even if the client
    # is not supposed to be built
    rm -rf $out/share/applications
    rm -rf $out/share/icons
    rm -rf $out/share/metainfo
  '';

  preFixup = lib.optionalString (stdenv.hostPlatform.isDarwin && buildClient) ''
    # Upstream links against <prefix>/lib while it installs this library in <prefix>/lib/ddnet
    install_name_tool -change "$out/lib/libsteam_api.dylib" "$out/lib/ddnet/libsteam_api.dylib" "$out/bin/DDNet"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-VKGc4LQjt2FHbELLBKtV8rKpxjGBrzlA3m9BSdZ/6Z0=";
  };

  checkTarget = "run_tests";

  meta = {
    description = "Teeworlds modification with a unique cooperative gameplay";

    longDescription = ''
      DDraceNetwork (DDNet) is an actively maintained version of DDRace,
      a Teeworlds modification with a unique cooperative gameplay.
      Help each other play through custom maps with up to 64 players,
      compete against the best in international tournaments,
      design your own maps, or run your own server.
    '';

    homepage = "https://ddnet.org";

    license = with lib.licenses; [
      zlib
      ofl
      cc-by-sa-30
    ];

    maintainers = with lib.maintainers; [
      Scrumplex
      sirseruju
    ];

    mainProgram = "DDNet${lib.optionalString (!buildClient) "-Server"}";
  };
}
