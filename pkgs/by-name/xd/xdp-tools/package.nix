{
  lib,
  stdenv,
  fetchFromGitHub,
  bpftools,
  buildPackages,
  elfutils,
  emacs-nox,
  fetchpatch,
  libbpf,
  libpcap,
  llvmPackages,
  m4,
  nukeReferences,
  pkg-config,
  wireshark-cli,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xdp-tools";
  version = "1.6.3";

  src = fetchFromGitHub {
    owner = "xdp-project";
    repo = "xdp-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wLSLDgACl6a6gQLvRiRR9HQFRMrGWYZAa5CcdzECExE=";
  };

  outputs = [
    "out"
    "lib"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-jYdcC36nL4P4IadwGfva8nqMerd/2HHw2RYhc+wR9nk=";
      name = "musl.patch";
      url = "https://github.com/xdp-project/xdp-tools/commit/2ff228be7926ba01e13c8d328828a270af2e7e0d.patch";
    })
  ];

  nativeBuildInputs = [
    bpftools
    llvmPackages.llvm
    pkg-config
    m4
    nukeReferences
  ];

  buildInputs = [
    libbpf
    elfutils
    libpcap
    zlib
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "LIBDIR=$(lib)/lib"
  ];

  env = {
    # When building BPF, the default CC wrapper is interfering a bit too much.
    BPF_CFLAGS = toString [
      "-fno-stack-protector"
      "-Wno-error=unused-command-line-argument"
    ];

    # When cross compiling, configure prefers the unwrapped clang unless told otherwise.
    CLANG = lib.getExe buildPackages.llvmPackages.clang;
    DYNAMIC_LIBXDP = 1;
    FORCE_EMACS = 1;
    FORCE_SYSTEM_LIBBPF = 1;
    PRODUCTION = 1;
  };

  nativeCheckInputs = [
    wireshark-cli # for tshark
  ];

  postInstall = ''
    # Note that even the static libxdp would refer to BPF_OBJECT_DIR ?=$(LIBDIR)/bpf
    rm "$lib"/lib/*.a
    # Drop unfortunate references to glibc.dev/include at least from $lib
    nuke-refs "$lib"/lib/bpf/*.o
  '';

  depsBuildBuild = [
    emacs-nox # to generate man pages from .org
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "zerocallusedregs" ];

  stripDebugList = [
    "bin"
    "lib"
    "share/xdp-tools"
  ];

  meta = {
    description = "Library and utilities for use with XDP";
    homepage = "https://github.com/xdp-project/xdp-tools";

    license = with lib.licenses; [
      gpl2Only
      lgpl21
      bsd2
    ];

    maintainers = with lib.maintainers; [
      tirex
      vcunat
      vifino
    ];

    platforms = lib.platforms.linux;
  };
})
