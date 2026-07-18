{
  lib,
  fetchFromGitHub,
  cmake,
  rustPlatform,
  versionCheckHook,
  writeShellScript,
}:
let
  version = "0.9.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "lovely-injector";

  src = fetchFromGitHub {
    owner = "ethangreen-dev";
    repo = "lovely-injector";
    tag = "v${version}";
    hash = "sha256-TzBxyIf7MjzsdFaJLBp2dXWNj5sOXyoMifaaztNIOog=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
  ];

  cargoHash = "sha256-4ECH8E/GuV2NYvvjSkanmj4gPIahY40HlCrhR2aFJ5M=";
  # lovely-injector depends on nightly rust features
  env.RUSTC_BOOTSTRAP = 1;
  # no tests
  doCheck = false;

  cargoBuildFlags = [
    "--package"
    "lovely-unix"
  ];

  meta = {
    description = "Runtime lua injector for games built with LÖVE";

    longDescription = ''
      Lovely is a lua injector which embeds code into a LÖVE 2d game at runtime.
      Unlike executable patchers, mods can be installed, updated, and removed over and over again without requiring a partial or total game reinstallation.
      This is accomplished through in-process lua API detouring and an easy to use (and distribute) patch system.
    '';

    homepage = "https://github.com/ethangreen-dev/lovely-injector";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.antipatico ];
    platforms = [ "x86_64-linux" ];
    downloadPage = "https://github.com/ethangreen-dev/lovely-injector/releases";
  };
}
