{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  perl,
  pkg-config,
  rdkafka,
  rustPlatform,
  enableAzure ? true,
  # these are features in the cargo, where one may be disabled to reduce the final size
  enableS3 ? true,
}:

assert lib.assertMsg (enableS3 || enableAzure) "Either S3 or azure support needs to be enabled";
rustPlatform.buildRustPackage {
  pname = "kafka-delta-ingest";
  version = "0-unstable-2025-05-05";

  src = fetchFromGitHub {
    owner = "delta-io";
    repo = "kafka-delta-ingest";
    rev = "da9c932be3a98649da74ed91f5e1593bece65e89";
    hash = "sha256-omeIuvi2OEU4jBWbE/EEM/nqHr25sy2+5Q9qsXzZh8E=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    openssl
    rdkafka
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  # #![deny(warnings)] breaks the build when newer rustc emits new lints.
  env.RUSTFLAGS = "--cap-lints warn";
  # many tests seem to require a running kafka instance
  doCheck = false;

  buildFeatures = [
    "dynamic-linking"
  ]
  ++ lib.optional enableS3 "s3"
  ++ lib.optional enableAzure "azure";

  meta = {
    description = "Highly efficient daemon for streaming data from Kafka into Delta Lake";
    homepage = "https://github.com/delta-io/kafka-delta-ingest";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "kafka-delta-ingest";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
