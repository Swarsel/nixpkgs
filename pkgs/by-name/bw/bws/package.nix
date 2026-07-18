{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  oniguruma,
  openssl,
  perl,
  pkg-config,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bws";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "bitwarden";
    repo = "sdk-sm";
    tag = "bws-v${finalAttrs.version}";
    hash = "sha256-cdiTdgNvUDN0/KzMDEiHo+GIYkUaWEZTAnWahBrMZ4I=";
  };

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    perl
  ];

  buildInputs = [
    oniguruma
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    openssl
  ];

  cargoHash = "sha256-zT6yPRxPuIf0E7OoUH4qQkUPADsYdkPirJ8dR/o5fV0=";

  env = {
    PYO3_PYTHON = "${python3}/bin/python3";
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd bws --"$shell" <($out/bin/bws completions "$shell")
    done
  '';

  cargoBuildFlags = [
    "--package"
    "bws"
  ];

  cargoTestFlags = [
    "--package"
    "bws"
  ];

  meta = {
    description = "Bitwarden Secrets Manager CLI";
    homepage = "https://bitwarden.com/help/secrets-manager-cli/";
    changelog = "https://github.com/bitwarden/sdk-sm/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unfree; # BITWARDEN SOFTWARE DEVELOPMENT KIT LICENSE AGREEMENT
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "bws";
  };
})
