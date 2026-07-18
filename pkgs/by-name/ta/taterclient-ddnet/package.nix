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
  glew,
  glslang,
  libGLU,
  libnotify,
  libogg,
  libx11,
  ninja,
  opusfile,
  pcre2,
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
}:
let
  clientExecutable = "TaterClient-DDNet";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "taterclient-ddnet";
  version = "10.8.7";

  src = fetchFromGitHub {
    owner = "TaterClient";
    repo = "TClient";
    tag = "V${finalAttrs.version}";
    hash = "sha256-jGi0eRKeYVGWes4AAzasKjdSqoYrEalxVHR/dYEzSXo=";
  };

  postPatch = ''
    substituteInPlace src/engine/shared/storage.cpp \
      --replace-fail "/usr/" "$out/"

    # Substitute date and time CMake macros. It avoids to the client being banned on some Teeworlds servers.
    substituteInPlace src/engine/client/client.cpp \
      --replace-fail "__DATE__" "\"$(date +'%b %e %Y')\"" \
      --replace-fail "__TIME__" "\"$(date +'%H:%M:%S')\""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    rustc
    cargo
    rustPlatform.cargoSetupHook
    glslang # for glslangValidator
    python3
  ];

  buildInputs = [
    curl
    libnotify
    pcre2
    sqlite
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
    glew
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];

  cmakeFlags = [
    (lib.cmakeBool "AUTOUPDATE" false)
    (lib.cmakeBool "CLIENT" true)
    (lib.cmakeBool "SERVER" false)
    (lib.cmakeBool "TOOLS" false)
    (lib.cmakeBool "DISCORD" false)
    (lib.cmakeFeature "CLIENT_EXECUTABLE" clientExecutable)
  ];

  # Since we are not building the server executable, the `run_tests` Makefile target
  # will not be generated.
  #
  # See https://github.com/TaterClient/TClient/blob/V10.8.6/CMakeLists.txt#L3260
  doCheck = false;

  postInstall = ''
    # Desktop application conflicts with the ddnet package
    mv "$out/share/applications/ddnet.desktop" "$out/share/applications/taterclient-ddnet.desktop"

    substituteInPlace $out/share/applications/taterclient-ddnet.desktop \
      --replace-fail "Exec=DDNet" "Exec=${clientExecutable}" \
      --replace-fail "Name=DDNet" "Name=TaterClient (DDNet)" \
      --replace-fail "Comment=Launch DDNet" "Comment=Launch ${clientExecutable}"
  '';

  preFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Upstream links against <prefix>/lib while it installs this library in <prefix>/lib/ddnet
    install_name_tool -change "$out/lib/libsteam_api.dylib" "$out/lib/ddnet/libsteam_api.dylib" "$out/bin/${clientExecutable}"
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname src version;
    hash = "sha256-VKGc4LQjt2FHbELLBKtV8rKpxjGBrzlA3m9BSdZ/6Z0=";
  };

  meta = {
    description = "Modification of DDNet teeworlds client";
    homepage = "https://github.com/sjrc6/taterclient-ddnet";
    changelog = "https://github.com/sjrc6/taterclient-ddnet/releases";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      melon
      theobori
    ];

    mainProgram = clientExecutable;
  };
})
