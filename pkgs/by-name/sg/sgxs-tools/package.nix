{
  lib,
  fetchCrate,
  openssl_3,
  pkg-config,
  protobuf,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sgxs-tools";
  version = "0.9.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-vLbSjDULrYL8emQTha4fhEbr00OlhXNa00QhCKCnWDc=";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [ openssl_3 ];
  cargoHash = "sha256-5JMChgqFny9bB8ur/5koW3/YFCOVjb7cDsn4Ki2FSzA=";

  meta = {
    description = "Utilities for working with the SGX stream format";
    homepage = "https://github.com/fortanix/rust-sgx";
    license = lib.licenses.mpl20;
    maintainers = [ lib.maintainers.ozwaldorf ];
    platforms = [ "x86_64-linux" ];
  };
})
