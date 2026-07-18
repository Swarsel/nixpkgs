{
  lib,
  stdenv,
  fetchFromGitHub,
  elfutils,
  # for passthru.tests
  knot-dns,
  nixosTests,
  pkg-config,
  systemd,
  tracee,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libbpf";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "libbpf";
    repo = "libbpf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-F92msxkYp4yZA3qUoSwS5GKUhcEO6DrYNln7w6U+jt0=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    elfutils
    zlib
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "--directory=src"
  ];

  postInstall = ''
    # install linux's libbpf-compatible linux/btf.h
    install -Dm444 include/uapi/linux/*.h -t $out/include/linux
  '';

  # FIXME: Multi-output requires some fixes to the way the pkg-config file is
  # constructed (it gets put in $out instead of $dev for some reason, with
  # improper paths embedded). Don't enable it for now.
  # outputs = [ "out" "dev" ];
  __structuredAttrs = true;
  enableParallelBuilding = true;

  passthru.tests = {
    inherit knot-dns tracee;
    bpf = nixosTests.bpf;
    systemd = systemd.override { withLibBPF = true; };
  };

  meta = {
    description = "Library for loading eBPF programs and reading and manipulating eBPF objects from user-space";
    homepage = "https://github.com/libbpf/libbpf";

    license = with lib.licenses; [
      lgpl21 # or
      bsd2
    ];

    maintainers = with lib.maintainers; [
      thoughtpolice
      vcunat
      saschagrunert
      martinetd
    ];

    platforms = lib.platforms.linux;
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "libbpf_project" finalAttrs.version;
  };
})
