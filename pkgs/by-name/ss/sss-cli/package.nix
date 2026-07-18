{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sss-cli";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dsprenkels";
    repo = "sss-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9Wht+t48SsWpj1z2yY6P7G+h9StmuqfMdODtyPffhak=";
  };

  cargoHash = "sha256-yutjlaqLf8R8KmdeKF+CHz/s/b6T+GB9bOl2liMBmMQ=";
  cargoPatches = [ ./fix-cargo-lock.patch ];

  meta = {
    description = "Command line program for secret-sharing strings";
    homepage = "https://github.com/dsprenkels/sss-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ laalsaas ];
  };
})
