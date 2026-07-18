{
  lib,
  stdenv,
  _experimental-update-script-combinators,
  callPackage,
  fetchFromSourcehut,
  pkg-config,
  river-classic,
  unstableGitUpdater,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zig_0_15,
}:

let
  zig = zig_0_15;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "river-bedload";
  version = "0.2.0";

  src = fetchFromSourcehut {
    owner = "~novakane";
    repo = "river-bedload";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MOZju7mU/AtaSm9CJgb/UqYpCg697tefJC1yvQPK3S8=";
  };

  nativeBuildInputs = [
    pkg-config
    zig
  ];

  buildInputs = [
    wayland
    wayland-protocols
    wayland-scanner
  ];

  deps = callPackage ./build.zig.zon.nix { };

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ];

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (unstableGitUpdater { tagPrefix = "v"; })
    ./update-build-zig-zon.sh
  ];

  meta = {
    inherit (river-classic.meta) platforms;
    description = "Display information about river in json in the STDOUT";
    homepage = "https://git.sr.ht/~novakane/river-bedload";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ adamcstephens ];
    mainProgram = "river-bedload";
  };
})
