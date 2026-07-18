{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fcft,
  pixman,
  pkg-config,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zig_0_14,
}:
let
  zig = zig_0_14;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "creek";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "nmeum";
    repo = "creek";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5TANQt/VWafm6Lj4dYViiK0IMy/chGr/Gzq0S66HZqI=";
  };

  nativeBuildInputs = [
    zig
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    fcft
    pixman
    wayland
    wayland-protocols
  ];

  deps = callPackage ./build.zig.zon.nix { };
  depsBuildBuild = [ pkg-config ];

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Malleable and minimalist status bar for the River compositor";
    homepage = "https://github.com/nmeum/creek";
    changelog = "https://github.com/nmeum/creek/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alexandrutocar ];
    platforms = lib.platforms.linux;
    mainProgram = "creek";
  };
})
