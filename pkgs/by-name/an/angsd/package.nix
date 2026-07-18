{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  curl,
  fetchpatch,
  htslib,
  openssl,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "angsd";
  version = "0.940";

  src = fetchFromGitHub {
    owner = "ANGSD";
    repo = "angsd";
    tag = finalAttrs.version;
    sha256 = "sha256-Ppxgy54pAnqJUzNX5c12NHjKTQyEEcPSpCEEVOyZ/LA=";
  };

  patches = [
    # Pull pending inclusion upstream patch for parallel buil fixes:
    #   https://github.com/ANGSD/angsd/pull/590
    (fetchpatch {
      hash = "sha256-KQgUfr3v8xc+opAm4qcSV2eaupztv4gzJJHyzJBCxqA=";
      name = "parallel-make.patch";
      url = "https://github.com/ANGSD/angsd/commit/89fd1d898078016df390e07e25b8a3eeadcedf43.patch";
    })
  ];

  buildInputs = [
    htslib
    zlib
    bzip2
    xz
    curl
    openssl
  ];

  makeFlags = [
    "HTSSRC=systemwide"
    "prefix=$(out)"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Program for analysing NGS data";
    homepage = "http://www.popgen.dk/angsd";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.bzizou ];
  };
})
