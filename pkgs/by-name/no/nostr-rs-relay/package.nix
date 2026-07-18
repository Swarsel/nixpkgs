{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nostr-rs-relay";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "scsibug";
    repo = "nostr-rs-relay";
    rev = finalAttrs.version;
    hash = "sha256-HNAoCb6NHfSXpz+qDsxeqSiV8ydd4f9/t5JfS5p9af4=";
  };

  nativeBuildInputs = [
    pkg-config # for openssl
    protobuf
  ];

  buildInputs = [
    openssl.dev
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  cargoHash = "sha256-zLLkAj1Kahkrahru7STSSdyzsLihc3z34c4v5BrFXvU=";

  meta = {
    description = "Nostr relay written in Rust";
    homepage = "https://sr.ht/~gheartsfield/nostr-rs-relay/";
    changelog = "https://github.com/scsibug/nostr-rs-relay/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jurraca ];
  };
})
