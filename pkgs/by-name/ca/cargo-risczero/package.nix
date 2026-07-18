{
  lib,
  fetchurl,
  fetchCrate,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:
let
  # That is from cargoDeps/risc0-circuit-recursion/build.rs
  src-recursion-hash = "744b999f0a35b3c86753311c7efb2a0054be21727095cf105af6ee7d3f4d8849";
  src-recursion = fetchurl {
    name = "cargo-risczero-recursion-source";
    outputHash = src-recursion-hash; # This hash should be the same as src-recuresion-hash
    outputHashAlgo = "sha256";
    url = "https://risc0-artifacts.s3.us-west-2.amazonaws.com/zkr/${src-recursion-hash}.zip";
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-risczero";
  version = "3.0.5";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-1tuY+XoZpilak9gc5vDnRDEB1SK+itBWoGNxwefT6xo=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-ayKQvhjYawPEl9ryVmDx4J93/EGPSeKds0mOnkRI2Fo=";

  env = {
    RECURSION_SRC_PATH = src-recursion;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cargo extension to help create, manage, and test RISC Zero projects";
    homepage = "https://risczero.com";
    license = with lib.licenses; [ asl20 ];
    maintainers = [ ];
    mainProgram = "cargo-risczero";
  };
})
