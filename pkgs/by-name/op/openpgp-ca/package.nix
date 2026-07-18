{
  lib,
  fetchFromGitLab,
  gnupg,
  nettle,
  nix-update-script,
  openssl,
  pcsclite,
  pkg-config,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openpgp-ca";
  version = "0.14.0";

  src = fetchFromGitLab {
    owner = "openpgp-ca";
    repo = "openpgp-ca";
    rev = "openpgp-ca/v${finalAttrs.version}";
    hash = "sha256-71SApct2yQV3ueWDlZv7ScK1s0nWWS57cPCvoMutlLA=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    sqlite
    pcsclite
    nettle
  ];

  cargoHash = "sha256-uftsBw8ZegnaoFel/wEqCMhVxiGR13jKbKqVSm+23T4=";
  # Most tests rely on gnupg being able to write to /run/user
  # gnupg refuses to respect the XDG_RUNTIME_DIR variable, so we skip the tests
  doCheck = false;

  nativeCheckInputs = [
    gnupg
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for managing OpenPGP keys within organizations";
    homepage = "https://openpgp-ca.org/";
    changelog = "https://openpgp-ca.org/doc/changelog/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ cherrykitten ];
    mainProgram = "oca";
  };
})
