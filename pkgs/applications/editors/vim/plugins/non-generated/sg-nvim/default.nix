{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  vimPlugins,
  vimUtils,
}:
let
  version = "1.1.0-unstable-2025-01-21";
  src = fetchFromGitHub {
    owner = "sourcegraph";
    repo = "sg.nvim";
    rev = "775f22b75a9826eabf69b0094dd1d51d619fe552";
    hash = "sha256-i5g+pzxB8pAORLbr1wlYWUTsrJJmVj9UwlCg8pU3Suw=";
  };

  sg-nvim-rust = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "sg-nvim-rust";
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ openssl ];
    cargoHash = "sha256-yY/5w2ztmTKJAYDxBJND8itCOwRNi1negiFq3PyFaSM=";
    env.OPENSSL_NO_VENDOR = true;
    # tests are broken
    doCheck = false;
    cargoBuildFlags = [ "--workspace" ];

    prePatch = ''
      rm .cargo/config.toml
    '';
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "sg.nvim";

  checkInputs = with vimPlugins; [
    telescope-nvim
    nvim-cmp
  ];

  postInstall = ''
    mkdir -p $out/target/debug
    ln -s ${sg-nvim-rust}/{bin,lib}/* $out/target/debug
  '';

  dependencies = [ vimPlugins.plenary-nvim ];

  nvimSkipModules = [
    # Dependent on active fuzzy search state
    "sg.cody.fuzzy"
    # Invokes a request that fails in the check hook
    # https://github.com/sourcegraph/sg.nvim/blob/775f22b75a9826eabf69b0094dd1d51d619fe552/lua/sg/health.lua#L2
    "sg.health"
  ];

  passthru = {
    # needed for the update script
    inherit sg-nvim-rust;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.sg-nvim.sg-nvim-rust";
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    description = "Neovim plugin designed to emulate the behaviour of the Cursor AI IDE";
    homepage = "https://github.com/sourcegraph/sg.nvim/";
    license = lib.licenses.asl20;
  };
}
