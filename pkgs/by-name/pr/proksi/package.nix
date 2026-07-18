{
  lib,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  yq,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "proksi";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "luizfonseca";
    repo = "proksi";
    tag = "proksi-v${finalAttrs.version}";
    hash = "sha256-AVNQBrFxkFPgnVbh3Y0CQ3RajMmh/M6ee/QkumdLDs4=";
  };

  postPatch = ''
    tomlq -ti 'del(.bench)' crates/proksi/Cargo.toml
  '';

  nativeBuildInputs = [
    pkg-config
    cmake # required for libz-ng-sys
    yq # for `tomlq`
  ];

  buildInputs = [
    openssl
    zstd
  ];

  cargoHash = "sha256-MYyPYZFmbQZszYViaGZdbUZWM739MN14J1ckyR8hXZc=";

  env = {
    OPENSSL_NO_VENDOR = true;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  checkFlags = [
    # requires network access
    "--skip=services::discovery::test::test_domain_addr"

    # these tests don't fail themselves, however they invoke clap which tries to parse configuration
    # from the command line, which would normally be empty, but here it includes the `--skip` flags
    # above which clap doesn't recognize and thus rejects
    "--skip=config::tests::"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoBuildFlags = [ "--package=proksi" ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=proksi-v(.*)" ]; };

  meta = {
    description = "Batteries-included CDN, reverse proxy and Load Balancer using Cloudflare Pingora";
    homepage = "https://github.com/luizfonseca/proksi";
    changelog = "https://github.com/luizfonseca/proksi/blob/proksi-v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ defelo ];
    mainProgram = "proksi";
  };
})
