{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  rustPlatform,
  vimUtils,
  writableTmpDirAsHomeHook,
  zig,
}:
let
  version = "0.9.6";
  src = fetchFromGitHub {
    owner = "dmtrKovalenko";
    repo = "fff.nvim";
    tag = "v${version}";
    hash = "sha256-JOoc4RDPIggZaoPtPEWhQ2msWfgOOuI4PPguFMczJls=";
  };
  fff-nvim-lib = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "fff-nvim-lib";

    nativeBuildInputs = [
      pkg-config
      perl
      rustPlatform.bindgenHook
      writableTmpDirAsHomeHook
      zig
    ];

    buildInputs = [
      openssl
    ];

    cargoHash = "sha256-nHVQccbKSfX9fZXh0aPRP33n4nHWhaRdz9k49apULME=";

    env = {
      OPENSSL_NO_VENDOR = true;
      # Allow undefined symbols on Darwin - they will be provided by Neovim's LuaJIT runtime
      RUSTFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-C link-arg=-undefined -C link-arg=dynamic_lookup";
    };

    # Some tests need git
    nativeCheckInputs = [ gitMinimal ];

    checkFlags = [
      # This test requires curl and GitHub access
      "--skip=update_check::tests::test_update_check_end_to_end"

      # This test depends on catching a race window and is not deterministic
      "--skip=drop_during_post_scan_does_not_crash"
    ];

    cargoBuildFlags = [
      "-p"
      "fff-nvim"
      "--features"
      "zlob"
    ];

    cargoCheckFlags = [
      "-p"
      "fff-nvim"
      "--features"
      "zlob"
    ];

    dontUseZigBuild = true;
    dontUseZigCheck = true;
    dontUseZigConfigure = true;
    dontUseZigInstall = true;

    # Tests need these permissions in order to use the FSEvents API on macOS.
    sandboxProfile = ''
      (allow mach-lookup (global-name "com.apple.FSEvents"))
    '';
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "fff.nvim";

  postPatch = ''
    substituteInPlace lua/fff/download.lua \
      --replace-fail \
        "return plugin_dir .. '/../target/release'" \
        "return '${fff-nvim-lib}/lib'"
  '';

  nvimSkipModules = [
    # Skip single file dev config for testing fff.nvim locally
    "empty_config"
  ];

  passthru = {
    # needed for the update script
    inherit fff-nvim-lib;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.fff-nvim.fff-nvim-lib";
    };
  };

  meta = {
    description = "Fast Fuzzy File Finder for Neovim";
    homepage = "https://github.com/dmtrKovalenko/fff.nvim";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      GaetanLepage
      saadndm
    ];
  };
}
