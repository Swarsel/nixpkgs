{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libheif,
  libx11,
  libxcursor,
  libxmu,
  libxpm,
  pkg-config,
  wayland,
  xbitmaps,
}:

buildGoModule (finalAttrs: {
  pname = "wallutils";
  version = "5.14.4";

  src = fetchFromGitHub {
    owner = "xyproto";
    repo = "wallutils";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LkS/rFoD3eb3UhOzJTO2hnuB2WFZNhQxExNnBObTMko=";
  };

  patches = [
    ./000-add-nixos-dirs-to-default-wallpapers.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libx11
    libxcursor
    libxmu
    libxpm
    libheif
    wayland
    xbitmaps
  ];

  vendorHash = null;

  checkFlags =
    let
      skippedTests = [
        "TestClosest" # Requiring Wayland or X
        "TestEveryMinute" # Blocking
        "TestNewSimpleEvent" # Blocking
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  excludedPackages = [
    "./pkg/event/cmd" # Development tools
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    inherit (wayland.meta) platforms;
    description = "Utilities for handling monitors, resolutions, and (timed) wallpapers";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    badPlatforms = lib.platforms.darwin;
  };
})
