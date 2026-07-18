{
  lib,
  stdenv,
  fetchFromGitHub,
  arrow-cpp,
  buildGoModule,
  duckdb,
  nix-update-script,
  vimPlugins,
  vimUtils,
}:
let
  version = "0.1.9";
  src = fetchFromGitHub {
    owner = "kndndrj";
    repo = "nvim-dbee";
    tag = "v${version}";
    hash = "sha256-AOime4vG0NFcUvsd9Iw5SxR7WaeCsoCRU6h5+vSkt4M=";
  };
  dbee-bin = buildGoModule {
    inherit version;
    inherit src;
    pname = "dbee-bin";

    buildInputs = [
      arrow-cpp
      duckdb
    ];

    vendorHash = "sha256-U/3WZJ/+Bm0ghjeNUILsnlZnjIwk3ySaX3Rd4L9Z62A=";
    # Tests attempt to access `/etc/protocols` which is forbidden in the sandbox
    doCheck = !stdenv.hostPlatform.isDarwin;
    sourceRoot = "${src.name}/dbee";
    meta.mainProgram = "dbee";
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "nvim-dbee";

  postPatch = ''
    substituteInPlace lua/dbee/install/init.lua \
      --replace-fail 'return vim.fn.stdpath("data") .. "/dbee/bin"' 'return "${dbee-bin}/bin"'
  '';

  preFixup = ''
    mkdir $target/bin
    ln -s ${lib.getExe dbee-bin} $target/bin/dbee
  '';

  dependencies = [ vimPlugins.nui-nvim ];

  passthru = {
    # needed for the update script
    inherit dbee-bin;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.nvim-dbee.dbee-bin";
    };
  };

  meta = {
    description = "Interactive database client for neovim";
    homepage = "https://github.com/kndndrj/nvim-dbee";
    changelog = "https://github.com/kndndrj/nvim-dbee/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ PerchunPak ];
  };
}
