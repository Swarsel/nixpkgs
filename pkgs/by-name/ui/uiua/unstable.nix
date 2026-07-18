rec {
  version = "0.19.0-dev.4";
  patches = [ ./0001-no-network-test.patch ];
  cargoHash = "sha256-cXD780n7qI8baDYyOdJvFBvXV2qCTiutgLc19+ewHnk=";
  hash = "sha256-Df/d6dCYXRG8uWVTpLR3I8llS1ujT3QFnx5TCZSxf+0=";
  tag = version;
  updateScript = ./update-unstable.sh;
}
