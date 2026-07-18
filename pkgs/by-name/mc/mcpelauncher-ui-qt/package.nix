{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  glfw,
  libzip,
  mcpelauncher-client,
  pkg-config,
  protobuf,
  qt6,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (mcpelauncher-client) version;
  pname = "mcpelauncher-ui-qt";

  src = fetchFromGitHub {
    owner = "minecraft-linux";
    repo = "mcpelauncher-ui-manifest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9NeUiiQ595lE6M/tD5G20l5W9PoInSPM2DgRqK92Bsk=";
    fetchSubmodules = true;
  };

  patches = [
    ./dont_download_glfw_ui.patch
    ./fix-cmake4-build.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    zlib
    libzip
    curl
    protobuf
    qt6.qtwebengine
    qt6.qtsvg
    qt6.qtwayland
    glfw
  ];

  # the program refuses to start when QT_STYLE_OVERRIDE is set
  # https://github.com/minecraft-linux/mcpelauncher-ui-qt/issues/25
  preFixup = ''
    qtWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ mcpelauncher-client ]}
      --unset QT_STYLE_OVERRIDE
    )
  '';

  meta = mcpelauncher-client.meta // {
    description = "Unofficial Minecraft Bedrock Edition launcher with GUI";
    mainProgram = "mcpelauncher-ui-qt";
  };
})
