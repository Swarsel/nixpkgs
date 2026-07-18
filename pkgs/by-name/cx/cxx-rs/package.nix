{
  lib,
  fetchFromGitHub,
  cxx-rs,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cxx-rs";
  version = "1.0.194";

  src = fetchFromGitHub {
    owner = "dtolnay";
    repo = "cxx";
    tag = finalAttrs.version;
    sha256 = "sha256-PIeF9VuyJOIs1x02YETKIP0+nCG3RZXLMJdFNlgAFzo=";
  };

  outputs = [
    "out"
    "doc"
    "dev"
  ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  postBuild = ''
    cargo doc --release
  '';

  postInstall = ''
    mkdir -p $doc
    cp -r ./target/doc/* $doc

    mkdir -p $dev/include/rust
    install -D -m 0644 ./include/cxx.h $dev/include/rust
  '';

  cargoBuildFlags = [
    "--workspace"
    "--exclude=demo"
  ];

  cargoTestFlags = [ "--workspace" ];

  passthru.tests.version = testers.testVersion {
    command = "cxxbridge --version";
    package = cxx-rs;
  };

  meta = {
    description = "Safe FFI between Rust and C++";
    homepage = "https://github.com/dtolnay/cxx";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ centromere ];
    mainProgram = "cxxbridge";
  };
})
