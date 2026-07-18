{
  lib,
  stdenv,
  fetchFromGitHub,
  libuv,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  vimUtils,
}:
let
  version = "2.0.5";
  src = fetchFromGitHub {
    owner = "mistricky";
    repo = "codesnap.nvim";
    tag = "v${version}";
    hash = "sha256-X631pK8pAAdQMO4uQUoNk+jL1V9BvAq3cIi4f5LMT5s=";
  };
  codesnap-lib = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "codesnap-lib";

    nativeBuildInputs = [
      pkg-config
      rustPlatform.bindgenHook
    ];

    buildInputs = [
      libuv.dev
      openssl
    ];

    cargoHash = "sha256-b+S56yRtly25fW1XmOVx5D3AT6PEY186r/KXVPI13dM=";

    env = {
      # Use system openssl
      OPENSSL_NO_VENDOR = 1;
      # Allow undefined symbols on Darwin - they will be provided by Neovim's LuaJIT runtime
      RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
    };

    postInstall = ''
      echo "${version}" > $out/lib/.version
    '';

    sourceRoot = "${src.name}/generator";
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "codesnap.nvim";

  postPatch =
    let
      extension = if stdenv.hostPlatform.isDarwin then "dylib" else "so";
    in
    ''
      substituteInPlace lua/codesnap/fetch.lua \
        --replace-fail \
          "local lib_name = get_platform_lib_name()" \
          "local lib_name = 'libgenerator.${extension}'" \
        --replace-fail \
          'local lib_dir = path_utils.join(sep, vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h:h"), "libs")' \
          'local lib_dir = "${codesnap-lib}/lib"'
    '';

  passthru = {
    # needed for the update script
    inherit codesnap-lib;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.codesnap-nvim.codesnap-lib";
    };
  };

  meta = {
    homepage = "https://github.com/mistricky/codesnap.nvim/";
    changelog = "https://github.com/mistricky/codesnap.nvim/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
