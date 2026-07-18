{
  lib,
  stdenv,
  cargo-hack,
  fetchCrate,
  libxml2,
  rustPlatform,
  rustc,
  zlib,
}:

rustPlatform.buildRustPackage rec {
  pname = "btfdump";
  version = "0.0.4";

  src = fetchCrate {
    inherit pname version;
    hash = "sha256-iLYGFXB4goiY7eJXXBhX9Y1TOltsW40ogeBhvTV2NvU=";
  };

  cargoHash = "sha256-uGp9XaqepceUmaEKBVEcu8oorfMAOk8BCPIHtun8Sto=";

  meta = {
    description = "BTF introspection tool";
    homepage = "https://github.com/anakryiko/btfdump";
    license = with lib.licenses; [ bsd2 ];
    maintainers = [ ];
    mainProgram = "btf";
  };
}
