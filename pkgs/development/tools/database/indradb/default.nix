{
  lib,
  stdenv,
  fetchFromGitHub,
  protobuf,
  rustPlatform,
  rustfmt,
}:
let
  src = fetchFromGitHub {
    owner = "indradb";
    repo = "indradb";
    rev = "06134dde5bb53eb1d2aaa52afdaf9ff3bf1aa674";
    sha256 = "sha256-g4Jam7yxMc+piYQzgMvVsNTF+ce1U3thzYl/M9rKG4o=";
  };

  meta = {
    description = "Graph database written in rust";
    homepage = "https://github.com/indradb/indradb";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ happysalada ];
    platforms = lib.platforms.unix;
    # Marked broken 2025-11-28 because both indradb-server and indradb-client
    # have failed on Hydra for nearly a year.
    broken = true;
  };
in
{
  indradb-client = rustPlatform.buildRustPackage {
    inherit src meta;
    pname = "indradb-client";
    version = "unstable-2021-01-05";

    nativeBuildInputs = [
      rustfmt
      rustPlatform.bindgenHook
    ];

    cargoHash = "sha256-wehQU0EOSkxQatoViqBJwgu4LG7NsbKjVZvKE6SoOFs=";
    env.PROTOC = "${protobuf}/bin/protoc";
    buildAndTestSubdir = "client";
  };

  indradb-server = rustPlatform.buildRustPackage {
    inherit src meta;
    pname = "indradb-server";
    version = "unstable-2021-01-05";

    nativeBuildInputs = [
      rustfmt
      rustPlatform.bindgenHook
    ];

    cargoHash = "sha256-wehQU0EOSkxQatoViqBJwgu4LG7NsbKjVZvKE6SoOFs=";
    env.PROTOC = "${protobuf}/bin/protoc";
    # test rely on libindradb and it can't be found
    # failure at https://github.com/indradb/indradb/blob/master/server/tests/plugins.rs#L63
    # `let _server = Server::start(&format!("../target/debug/libindradb_plugin_*.{}", LIBRARY_EXTENSION)).unwrap();`
    doCheck = false;
    buildAndTestSubdir = "server";
  };
}
