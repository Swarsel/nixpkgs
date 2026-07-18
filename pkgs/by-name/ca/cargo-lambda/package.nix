{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  curl,
  makeWrapper,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  zig_0_13,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-lambda";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "cargo-lambda";
    repo = "cargo-lambda";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Fbrt5zUC5dIfQO6UI0GnZxxLlI4q6tYoDw6ucKR+ouM=";
  };

  # Remove files that don't make builds reproducible:
  # - Remove build.rs file that adds the build date to the version.
  # - Remove cargo_lambda.rs that contains tests that reach the network.
  postPatch = ''
    rm crates/cargo-lambda-cli/build.rs
    rm crates/cargo-lambda-cli/tests/cargo_lambda.rs
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    curl
  ];

  cargoHash = "sha256-AlKty5tpb9plk/rmFso6kWKKbhuxcsH5zDX/xvK5oao=";
  env.CARGO_LAMBDA_BUILD_INFO = "(nixpkgs)";
  nativeCheckInputs = [ cacert ];

  checkFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    # Fails in darwin sandbox, first because of trying to listen to a port on
    # localhost. While this would be fixed by `__darwinAllowLocalNetworking = true;`,
    # they then fail with other I/O issues.
    "--skip=test::test_download_example"
    "--skip=test::test_download_example_with_cache"
  ];

  postInstall = ''
    wrapProgram $out/bin/cargo-lambda --prefix PATH : ${lib.makeBinPath [ zig_0_13 ]}
  '';

  cargoBuildFlags = [ "--features=skip-build-banner" ];
  cargoCheckFlags = [ "--features=skip-build-banner" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cargo subcommand to help you work with AWS Lambda";
    homepage = "https://cargo-lambda.info";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      taylor1791
      calavera
      matthiasbeyer
    ];

    mainProgram = "cargo-lambda";
  };
})
