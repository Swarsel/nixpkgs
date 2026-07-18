{
  lib,
  mkMesonExecutable,

  nix-util,
  # Configuration Options

  version,
}:

let
  inherit (lib) fileset;
in

mkMesonExecutable (finalAttrs: {
  inherit version;
  pname = "nix-nswrapper";

  buildInputs = [
    nix-util
  ];

  mesonFlags = [
  ];

  fileset = fileset.unions [
    ../../nix-meson-build-support
    ./nix-meson-build-support
    ../../.version
    ./.version
    ./meson.build

    (fileset.fileFilter (file: file.hasExt "cc") ./.)
    (fileset.fileFilter (file: file.hasExt "hh") ./.)
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.linux;
    mainProgram = "nix-nswrapper";
  };

})
