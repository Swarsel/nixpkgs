{
  lib,
  fetchFromGitHub,
  oniguruma,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kty";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "grampelberg";
    repo = "kty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E9PqWDBKYJFYOUNyjiK+AM2WULMiwupFWTOQlBH+6d4=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    oniguruma
  ];

  cargoHash = "sha256-nJ+nof2YhyLrNuLVy69kYj5tw+aG4IJm6nVxHkczbko=";

  env = {
    OPENSSL_NO_VENDOR = 1;
    RUSTONIG_SYSTEM_LIBONIG = 1;
  };

  meta = {
    description = "Terminal for Kubernetes";
    homepage = "https://kty.dev/";
    changelog = "https://github.com/grampelberg/kty/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "kty";
  };
})
