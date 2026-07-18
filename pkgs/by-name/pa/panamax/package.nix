{
  lib,
  fetchCrate,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "panamax";
  version = "1.0.14";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-gIgw6JMGpHNXE/PZoz3jRdmjIWy4hETYf24Nd7/Jr/g=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  cargoHash = "sha256-QjzmB9nKL2TfDNi7lOVaFSEfKiDSuYWnrmqeesrhuyQ=";

  meta = {
    description = "Mirror rustup and crates.io repositories for offline Rust and cargo usage";
    homepage = "https://github.com/panamax-rs/panamax";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = [ ];
    mainProgram = "panamax";
  };
})
