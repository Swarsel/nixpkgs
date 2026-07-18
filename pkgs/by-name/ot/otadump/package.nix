{
  lib,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  rustPlatform,
  xz,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "otadump";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "crazystylus";
    repo = "otadump";
    rev = finalAttrs.version;
    hash = "sha256-4zPVcTU+0otV4EPQi80uSRkpRo9XzI0V3Kr17ugXX2U=";
  };

  patches = [ ./no-static.patch ];

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [ xz ];
  cargoHash = "sha256-6L1FJWEaDBqpJvj9uGjYuAqqDoQlkVwOWfbG46Amkkw=";
  doCheck = false; # There are no tests

  meta = {
    description = "Command-line tool to extract partitions from Android OTA files";
    homepage = "https://github.com/crazystylus/otadump";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.axka ];
    mainProgram = "otadump";
  };
})
