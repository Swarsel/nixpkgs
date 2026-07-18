{
  lib,
  fetchCrate,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "protoc-gen-rust";
  version = "3.5.0";

  src = fetchCrate {
    inherit version;
    hash = "sha256-yGZ4auZHGtcsN6n4/FEzabsSXproyhNTJHIwujt7ijg=";
    pname = "protobuf-codegen";
  };

  nativeBuildInputs = [ protobuf ];
  cargoHash = "sha256-cj+/X3soc//lMOmBjfjQT+QhY/EWP92gChiDQ7b2fsM=";

  cargoBuildFlags = [
    "--bin"
    pname
  ];

  meta = {
    description = "Protobuf plugin for generating Rust code";
    homepage = "https://github.com/stepancheg/rust-protobuf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lucperkins ];
    mainProgram = "protoc-gen-rust";
  };
}
