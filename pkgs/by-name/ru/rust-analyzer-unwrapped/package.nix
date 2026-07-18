{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libiconv,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  doCheck ? true,
  useMimalloc ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit doCheck;
  pname = "rust-analyzer-unwrapped";
  version = "2026-06-15";

  src = fetchFromGitHub {
    owner = "rust-lang";
    repo = "rust-analyzer";
    rev = finalAttrs.version;
    hash = "sha256-+V3nK4pCngbmgyVGXY6Kkrlevp4ocPkJJLf2aqwkDNA=";
  };

  nativeBuildInputs = lib.optional useMimalloc cmake;

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-gVQGlbO6ylFNWt1JwGu8v4oLT7DBy23FGCnbP67Dj/0=";
  env.CFG_RELEASE = finalAttrs.version;
  # Code format check requires more dependencies but don't really matter for packaging.
  # So just ignore it.
  checkFlags = [ "--skip=tidy::check_code_formatting" ];

  preCheck = lib.optionalString doCheck ''
    export RUST_SRC_PATH=${rustPlatform.rustLibSrc}
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildFeatures = lib.optional useMimalloc "mimalloc";

  cargoBuildFlags = [
    "--bin"
    "rust-analyzer"
    "--bin"
    "rust-analyzer-proc-macro-srv"
  ];

  cargoTestFlags = [
    "--package"
    "rust-analyzer"
    "--package"
    "proc-macro-srv-cli"
  ];

  passthru = {
    updateScript = nix-update-script { };
    # FIXME: Pass overrided `rust-analyzer` once `buildRustPackage` also implements #119942
    # FIXME: test script can't find rust std lib so hover doesn't return expected result
    # https://github.com/NixOS/nixpkgs/pull/354304
    # tests.neovim-lsp = callPackage ./test-neovim-lsp.nix { };
  };

  meta = {
    description = "Language server for the Rust language";
    homepage = "https://rust-analyzer.github.io";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ oxalica ];
    mainProgram = "rust-analyzer";
  };
})
