{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bash,
  bzip2,
  curl,
  htslib,
  perl,
  python3,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bcftools";
  version = "1.22";

  src = fetchFromGitHub {
    owner = "samtools";
    repo = "bcftools";
    tag = finalAttrs.version;
    hash = "sha256-S+FuqjiOf38sAQKWYOixv/MlXGnuDmkx9z4Co/pk/eM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    perl
    python3
  ];

  buildInputs = [
    htslib
    zlib
    bzip2
    xz
    curl
  ];

  makeFlags = [
    "HSTDIR=${htslib}"
    "prefix=$(out)"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  doCheck = true;

  nativeCheckInputs = [
    htslib
  ];

  preCheck = ''
    patchShebangs misc/
    patchShebangs test/
    sed -i -e 's|/bin/bash|${bash}/bin/bash|' test/test.pl
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Tools for manipulating BCF2/VCF/gVCF format, SNP and short indel sequence variants";
    homepage = "http://www.htslib.org/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mimame ];
    platforms = lib.platforms.unix;
  };
})
