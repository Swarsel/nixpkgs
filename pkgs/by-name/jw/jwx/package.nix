{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "jwx";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "lestrrat-go";
    repo = "jwx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+u2PR1L66cua6iGer9qYlnPpfYt1j9cZ0PSrWntpYp0=";
  };

  vendorHash = "sha256-dxC00wr51c48yxdCUWsL44RMmk+pBmqXkUQqjP90GNU=";
  env.GOEXPERIMENT = "jsonv2";
  sourceRoot = "${finalAttrs.src.name}/cmd/jwx";

  meta = {
    description = "Implementation of various JWx (Javascript Object Signing and Encryption/JOSE) technologies";
    homepage = "https://github.com/lestrrat-go/jwx";
    changelog = "https://github.com/lestrrat-go/jwx/blob/v${finalAttrs.version}/Changes";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      arianvp
      flokli
    ];

    mainProgram = "jwx";
  };
})
