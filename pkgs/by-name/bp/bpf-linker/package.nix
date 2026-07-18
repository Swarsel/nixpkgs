{
  lib,
  fetchFromGitHub,
  btfdump,
  libxml2,
  rustPlatform,
  rustc,
  zlib,
  # Override this if you are compiling your BPF programs with a version of
  # rustc that uses a different LLVM version, for example when using a rust
  # overlay.
  llvmPackagesForLinker ? rustc.llvmPackages,
}:
rustPlatform.buildRustPackage rec {
  pname = "bpf-linker";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "aya-rs";
    repo = "bpf-linker";
    tag = "v${version}";
    hash = "sha256-W1ZrKSkAHH1CBFNhyD5qfVJuf9mhwzZuzkdWGX4prnI=";
  };

  buildInputs = [
    zlib
    libxml2
    (lib.getLib llvmPackagesForLinker.llvm)
  ];

  cargoHash = "sha256-jgVuJ5xq/M2Bq1B1u8BnULqSsbwxXpSsIFhVU8ehDZM=";

  nativeCheckInputs = [
    btfdump
    llvmPackagesForLinker.clang.cc
    llvmPackagesForLinker.llvm
  ];

  buildFeatures = [ "llvm-${lib.versions.major llvmPackagesForLinker.llvm.version}" ];
  buildNoDefaultFeatures = true;

  meta = {
    description = "Simple BPF static linker";
    homepage = "https://github.com/aya-rs/bpf-linker";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "bpf-linker";
  };
}
