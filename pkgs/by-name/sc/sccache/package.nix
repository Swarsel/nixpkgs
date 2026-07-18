{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  distributed ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sccache";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "sccache";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-OShSodMh3RWB/XWsUwW5jaJ5KLRCrcrPG1DsehDiKc4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-65wx8fQHqcRLWYQvbsPCEDxlOmaCs3azQCPYacHXYL8=";
  # Tests fail because of client server setup which is not possible inside the
  # pure environment, see https://github.com/mozilla/sccache/issues/460
  doCheck = false;

  buildFeatures = lib.optionals distributed [
    "dist-client"
    "dist-server"
  ];

  meta = {
    description = "Ccache with Cloud Storage";
    homepage = "https://github.com/mozilla/sccache";
    changelog = "https://github.com/mozilla/sccache/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      doronbehar
    ];

    mainProgram = "sccache";
  };
})
