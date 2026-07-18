{
  lib,
  stdenv,
  fetchCrate,
  installShellFiles,
  libiconv,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  sqlx-cli,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sqlx-cli";
  version = "0.9.0";

  # Upstream stopped shipping a Cargo.lock starting with the v0.9.0 release
  # https://github.com/transact-rs/sqlx/blob/v0.9.0/CHANGELOG.md#cargolock-removed-from-tracking
  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-XariusjsCgn0Qai0XWtr7EzSzDDTp1cCzjff1kJNO9Y=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      openssl
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ];

  cargoHash = "sha256-pHaMKuB9v3fjbgeVyLyRtfoQ9BkE6z+TjDfdBaVdbXM=";

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/sqlx completions $shell > sqlx.$shell
      installShellCompletion sqlx.$shell
    done
  '';

  buildFeatures = [
    "native-tls"
    "postgres"
    "sqlite"
    "mysql"
    "completions"
    "sqlx-toml"
  ];

  buildNoDefaultFeatures = true;

  passthru.tests.version = testers.testVersion {
    command = "sqlx --version";
    package = sqlx-cli;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI for managing databases, migrations, and enabling offline mode with `sqlx::query!()` and friends";
    homepage = "https://github.com/transact-rs/sqlx";
    changelog = "https://github.com/transact-rs/sqlx/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      greizgh
      xrelkd
      fd
    ];

    mainProgram = "sqlx";
  };
})
