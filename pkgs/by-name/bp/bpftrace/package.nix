{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  bcc,
  bison,
  cereal,
  cmake,
  elfutils,
  fetchpatch,
  flex,
  glibc,
  libbfd,
  libbpf,
  libopcodes,
  llvmPackages,
  nixosTests,
  pkg-config,
  util-linux,
  xxd,
}:

stdenv.mkDerivation rec {
  pname = "bpftrace";
  version = "0.26.1";

  src = fetchFromGitHub {
    owner = "bpftrace";
    repo = "bpftrace";
    rev = "v${version}";
    hash = "sha256-h3gFnQq48oM5uK07xrykOCSJxhr6dqcyVUDoIKIRREY=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    flex
    bison
    llvmPackages.llvm.dev
    util-linux
    xxd
  ];

  buildInputs = with llvmPackages; [
    llvm
    libclang
    elfutils
    bcc
    libbpf
    libbfd
    libopcodes
    cereal
    asciidoctor
  ];

  cmakeFlags = [
    "-DLIBBCC_INCLUDE_DIRS=${bcc}/include"
    "-DUSE_SYSTEM_LIBBPF=ON"
    "-DSYSTEM_INCLUDE_PATHS=${glibc.dev}/include"
  ];

  # Pull BPF scripts into $PATH (next to their bcc program equivalents), but do
  # not move them to keep `${pkgs.bpftrace}/share/bpftrace/tools/...` working.
  postInstall = ''
    ln -sr $out/share/bpftrace/tools/*.bt $out/bin/
    # do not use /usr/bin/env for shipped tools
    # If someone can get patchShebangs to work here please fix.
    sed -i -e "1s:#!/usr/bin/env bpftrace:#!$out/bin/bpftrace:" $out/share/bpftrace/tools/*.bt
  '';

  passthru.tests = {
    inherit (nixosTests) bpf;
  };

  meta = {
    description = "High-level tracing language for Linux eBPF";
    homepage = "https://github.com/bpftrace/bpftrace";
    changelog = "https://github.com/bpftrace/bpftrace/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      rvl
      thoughtpolice
      martinetd
      mfrw
      illustris
    ];

    platforms = lib.platforms.linux;
    mainProgram = "bpftrace";
  };
}
