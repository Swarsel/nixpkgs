{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  expat,
  fontconfig,
  freetype,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  makeWrapper,
  pkg-config,
  rustPlatform,
  udev,
  vulkan-loader,
  wayland,
}:

let
  runtimeLibs = [
    expat
    fontconfig
    freetype
    freetype.dev
    libGL
    pkg-config
    udev
    wayland
    libxkbcommon
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "liana";
  version = "14.0"; # keep in sync with lianad

  src = fetchFromGitHub {
    owner = "wizardsardine";
    repo = "liana";
    tag = "v${version}";
    hash = "sha256-1d+icjk1NamlvEx4Xb1Ao4d1hb/t5aBwho+yCtHF9y4=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    udev
  ];

  cargoHash = "sha256-9CWJIRby6QWJmkYSHj2lFfEj0plX5iWxsdQs5sYww7Q=";
  doCheck = true;

  postInstall = ''
    install -Dm0644 ./liana-ui/static/logos/liana-app-icon.svg $out/share/icons/hicolor/scalable/apps/liana.svg
    wrapProgram $out/bin/liana-gui --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"
  '';

  buildAndTestSubdir = "liana-gui";

  desktopItems = [
    (makeDesktopItem {
      comment = meta.description;
      desktopName = "Liana";
      exec = "liana-gui";
      icon = "liana";
      name = "Liana";
    })
  ];

  meta = {
    description = "Bitcoin wallet leveraging on-chain timelocks for safety and recovery";
    homepage = "https://wizardsardine.com/liana";
    changelog = "https://github.com/wizardsardine/liana/releases/tag/${src.rev}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dunxen ];
    platforms = lib.platforms.linux;
    mainProgram = "liana-gui";
    broken = stdenv.hostPlatform.isAarch64;
  };
}
