{
  lib,
  stdenv,
  fetchFromGitHub,
  bpftools,
  clang,
  docutils,
  libbpf,
  libcap,
  libnl,
  nix-update-script,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bpftune";
  version = "0.4-2";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "bpftune";
    tag = finalAttrs.version;
    hash = "sha256-clfR2nZKB9ztfUEw+znr9/Rdefv4K+mTeRCSBLIBmVY=";
  };

  postPatch = ''
    # otherwise shrink rpath would drop $out/lib from rpath
    substituteInPlace src/Makefile \
      --replace-fail /sbin /bin \
      --replace-fail ldconfig true
    substituteInPlace src/bpftune.service \
      --replace-fail /usr/sbin/bpftune "$out/bin/bpftune"
  '';

  nativeBuildInputs = [
    clang
    bpftools
    docutils # rst2man
  ];

  buildInputs = [
    libbpf
    libcap
    libnl
  ];

  makeFlags = [
    "prefix=${placeholder "out"}"
    "confprefix=${placeholder "out"}/etc"
    "libdir=lib"
    "BPFTUNE_VERSION=${finalAttrs.version}"
    "NL_INCLUDE=${lib.getDev libnl}/include/libnl3"
    "BPF_INCLUDE=${lib.getDev libbpf}/include"
  ];

  enableParallelBuilding = true;

  hardeningDisable = [
    "zerocallusedregs"
  ];

  passthru = {
    tests = {
      inherit (nixosTests) bpftune;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "BPF-based auto-tuning of Linux system parameters";
    homepage = "https://github.com/oracle-samples/bpftune";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ nickcao ];
    mainProgram = "bpftune";
  };
})
