{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
  vimUtils,
}:
let
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "Saghen";
    repo = "blink.pairs";
    tag = "v${version}";
    hash = "sha256-PTbj6jlXNRUOmwFSplvRDDiyyGqkBzUKtuBrvZm9kzM=";
  };

  blink-pairs-lib = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "blink-pairs";

    nativeBuildInputs = [
      pkg-config
    ];

    cargoHash = "sha256-Cn9zRsQkBwaKbBD/JEpFMBOF6CBZTDx7fQa6Aoic4YU=";

    env = {
      RUSTC_BOOTSTRAP = 1;
      # Allow undefined symbols on Darwin - they will be provided by Neovim's LuaJIT runtime
      RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
    };

    # NOTE: Disabled upstream too
    doCheck = false;
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "blink.pairs";

  preInstall =
    let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      mkdir -p target/release
      ln -s ${blink-pairs-lib}/lib/libblink_pairs${ext} target/release/
    '';

  nvimSkipModules = [
    # a module to quickly setup a minimal reproduction environment for testing
    # bugs. therefore mostly useless from a consumer side
    "repro"
  ];

  passthru = {
    # needed for the update script
    inherit blink-pairs-lib;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.blink-pairs.blink-pairs-lib";
    };
  };

  meta = {
    description = "Rainbow highlighting and intelligent auto-pairs for Neovim";
    homepage = "https://github.com/Saghen/blink.pairs";
    changelog = "https://github.com/Saghen/blink.pairs/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
