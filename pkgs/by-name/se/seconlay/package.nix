{
  lib,
  fetchFromGitLab,
  cloud-utils,
  nix-update-script,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seconlay";
  version = "0-unstable-2026-07-07";

  src = fetchFromGitLab {
    owner = "scl";
    repo = "scl-management";
    rev = "1b70d57d1da333625fba7c8878718924597e50d7";
    hash = "sha256-JRNdsLCHS9QTb6AefPXVETLjQzRu0GkUYl4kEoaSq8Q=";
    group = "alasca.cloud";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    openssl
    zlib
  ];

  cargoHash = "sha256-aX5HL/zDdrQ+V4vCYZrqlO2vNWuvF4GW2P30jtbv1tE=";
  doCheck = true;
  nativeCheckInputs = [ cloud-utils ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Minimal IaaS system with strong tenant separation and small TCB";

    longDescription = ''
      Seconlay (commonly abbreviated as SCL) is a minimal IaaS system built in Rust with strong tenant separation and small TCB.
      It is intended for providing an easy-to-use API to manage a VM-based separation layer underlying to user-facing infrastructure such as tenant-specific Kubernetes clusters.
    '';

    homepage = "https://alasca.cloud/projects/seconlay/";
    license = lib.licenses.eupl12;

    maintainers = with lib.maintainers; [
      malik
      messemar
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "sclctl";
  };
})
