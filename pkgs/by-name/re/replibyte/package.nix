{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "replibyte";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "Qovery";
    repo = "replibyte";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VExA92g+1y65skxLKU62ZPUPOwdm9N73Ne9xW7Q0Sic=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-RPY1M5zRMYgzICn2BBJrIn3LFa6T9PKBfpPUXtkgeQo=";
  # Fix undefined reference to `__rust_probestack` from wasmer_vm.
  # Define it as a no-op since it's only needed for stack overflow detection.
  env.RUSTFLAGS = "-C link-arg=-Wl,--defsym,__rust_probestack=0";
  doCheck = false; # requires multiple dbs to be installed
  cargoBuildFlags = [ "--all-features" ];

  cargoPatches = [
    ./bump-crates.patch
  ];

  meta = {
    description = "Seed your development database with real data";
    homepage = "https://github.com/Qovery/replibyte";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "replibyte";
  };
})
