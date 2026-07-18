{
  lib,
  stdenv,
  fetchFromGitHub,
  elfutils,
  nixosTests,
  pkg-config,
  zlib,
}:

# update bot does not seem to limit updates here to 0.8.x despite
# the all-packages derivation being libbpf_0 as the libbpf base alias
# is still present: just disable it for 0.x:
# nixpkgs-update: no auto update

stdenv.mkDerivation rec {
  pname = "libbpf";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "libbpf";
    repo = "libbpf";
    rev = "v${version}";
    sha256 = "sha256-J5cUvfUYc+uLdkFa2jx/2bqBoZg/eSzc6SWlgKqcfIc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    elfutils
    zlib
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "-C src"
  ];

  postInstall = ''
    # install linux's libbpf-compatible linux/btf.h
    install -Dm444 include/uapi/linux/*.h -t $out/include/linux
  '';

  enableParallelBuilding = true;

  passthru.tests = {
    bpf = nixosTests.bpf;
  };

  # FIXME: Multi-output requires some fixes to the way the pkg-config file is
  # constructed (it gets put in $out instead of $dev for some reason, with
  # improper paths embedded). Don't enable it for now.
  # outputs = [ "out" "dev" ];
  meta = {
    description = "Upstream mirror of libbpf";
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
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "libbpf_project" version;
  };
}
