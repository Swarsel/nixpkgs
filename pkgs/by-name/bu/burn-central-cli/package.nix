{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "burn-central-cli";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "tracel-ai";
    repo = "tracel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1QXlN1cq5MKZAPgGx5mnf8Jy7o4CnKJDKi0sSith6n0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    # Pulled in by flate2
    zlib
  ];

  cargoHash = "sha256-c0DfH5wtm/aiK8Mcf7xqVqnFzByMKkbspF1reeGZNJw=";
  __structuredAttrs = true;
  buildAndTestSubdir = "crates/burn-central-cli";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line tool for interacting with Burn Central";

    longDescription = ''
      The Burn Central CLI (burn) is the command-line tool for interacting
      with Burn Central, the centralized platform for experiment tracking,
      model sharing, and deployment for Burn users.
    '';

    homepage = "https://github.com/tracel-ai/tracel-cli";
    changelog = "https://github.com/tracel-ai/tracel-cli/releases/tag/v${finalAttrs.version}";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ kilyanni ];
    mainProgram = "burn";
  };
})
