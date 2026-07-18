{
  lib,
  fetchFromGitHub,
  clangStdenv,
  elfutils,
  libbpf,
  pkg-config,
  rustPlatform,
  zlib,
}:
rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } (finalAttrs: {
  pname = "bpftop";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "jfernandez";
    repo = "bpftop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QukcBq80tASPSHRg1yRouYiZqvca+ipp6RGzXqP2CwA=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    elfutils
    libbpf
    zlib
  ];

  cargoHash = "sha256-33VamoVq8O4cgdweWRaDqo5ey2lbLAHoPQVPgmyQwh0=";

  hardeningDisable = [
    "zerocallusedregs"
  ];

  meta = {
    description = "Dynamic real-time view of running eBPF programs";
    homepage = "https://github.com/jfernandez/bpftop";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      _0x4A6F
      luftmensch-luftmensch
      mfrw
    ];

    mainProgram = "bpftop";
  };
})
