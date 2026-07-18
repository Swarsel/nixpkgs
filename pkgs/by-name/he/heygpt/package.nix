{
  lib,
  fetchFromGitHub,
  openssl,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "heygpt";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "fuyufjh";
    repo = "heygpt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-oP0yIdYytXSsbZ2pNaZ8Rrak1qJsudTe/oP6dGncGUM=";
  };

  nativeBuildInputs = [ openssl ];
  cargoHash = "sha256-z5Y/dhDEAd6JcWItlGyH+kDxHxIiyJw0KrjiTDT+Fwc=";

  env = {
    OPENSSL_DIR = "${lib.getDev openssl}";
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
  };

  meta = {
    description = "Simple command-line interface for ChatGPT API";
    homepage = "https://github.com/fuyufjh/heygpt";
    changelog = "https://github.com/fuyufjh/heygpt/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aldoborrero ];
    mainProgram = "heygpt";
  };
})
