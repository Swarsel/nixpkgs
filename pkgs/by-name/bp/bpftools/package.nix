{
  lib,
  stdenv,
  bison,
  buildPackages,
  elfutils,
  flex,
  libbfd,
  libbfd_2_38,
  libopcodes,
  libopcodes_2_38,
  linuxHeaders,
  openssl,
  python3,
  readline,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (linuxHeaders) version src;
  pname = "bpftools";

  patches = [
    # fix unknown type name '__vector128' on powerpc64*
    # https://www.spinics.net/lists/bpf/msg28613.html
    ./include-asm-types-for-powerpc64.patch
  ];

  nativeBuildInputs = [
    python3
    bison
    flex
  ];

  buildInputs =
    (
      if (lib.versionAtLeast finalAttrs.version "5.20") then
        [
          libopcodes
          libbfd
        ]
      else
        [
          libopcodes_2_38
          libbfd_2_38
        ]
    )
    ++ [
      elfutils
      zlib
      openssl
      readline
    ];

  # needed for cross to riscv64
  makeFlags = [ "ARCH=${stdenv.hostPlatform.linuxArch}" ];

  buildFlags = [
    "bpftool"
    "bpf_asm"
    "bpf_dbg"
  ];

  preConfigure = ''
    patchShebangs scripts/bpf_doc.py

    cd tools/bpf
    substituteInPlace ./bpftool/Makefile \
      --replace '/usr/local' "$out" \
      --replace '/usr'       "$out" \
      --replace '/sbin'      '/bin'
  '';

  installPhase = ''
    make -C bpftool install
    install -Dm755 -t $out/bin bpf_asm
    install -Dm755 -t $out/bin bpf_dbg
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  separateDebugInfo = true;

  meta = {
    description = "Debugging/program analysis tools for the eBPF subsystem";
    homepage = "https://github.com/libbpf/bpftool";

    license = [
      lib.licenses.gpl2Only
      lib.licenses.bsd2
    ];

    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.linux;
  };
})
