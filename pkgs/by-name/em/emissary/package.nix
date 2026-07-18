{
  lib,
  fetchFromGitHub,
  fontconfig,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "emissary";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "eepnet";
    repo = "emissary";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fLhvMzdxXAuEB99NgIfTLxYezIIZVaC8Z6snK9UUEl0=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    fontconfig
  ];

  cargoHash = "sha256-ZboA5wO3vitts6L/tQc23z7bIFmFdj1freXHBoDl06k=";
  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Rust implementation of the I2P protocol stack";
    homepage = "https://altonen.github.io/emissary/";
    changelog = "https://github.com/eepnet/emissary/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit; # https://github.com/eepnet/emissary/blob/master/LICENSE (found an apache2 as well but thats for https://github.com/eepnet/emissary/commit/c4a1c849ebfceba892adce53f512f1f099721de2)
    maintainers = [ lib.maintainers.N4CH723HR3R ];
    mainProgram = "emissary-cli";
  };
})
