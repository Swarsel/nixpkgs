{
  lib,
  stdenv,
  fetchFromGitLab,
  apfel,
  apfelgrid,
  applgrid,
  blas,
  ceres-solver,
  cmake,
  gfortran,
  gsl,
  lapack,
  lhapdf,
  libtirpc,
  libyaml,
  pkg-config,
  qcdnum,
  root,
  yaml-cpp,
  zlib,
}:

stdenv.mkDerivation {
  pname = "xfitter";
  version = "2.2.0";

  src = fetchFromGitLab {
    owner = "fitters";
    repo = "xfitter";
    tag = "2.2.0_Future_Freeze";
    hash = "sha256-wanxgldvBEuAEOeVok3XgRVStcn9APd+Nj7vpRZUtGs=";
    domain = "gitlab.cern.ch";
  };

  patches = [
    # Avoid need for -fallow-argument-mismatch
    ./0001-src-GetChisquare.f-use-correct-types-in-calls-to-DSY.patch
  ];

  nativeBuildInputs = [
    cmake
    gfortran
    pkg-config
  ];

  buildInputs = [
    apfel
    apfelgrid
    applgrid
    blas
    ceres-solver
    lhapdf
    lapack
    libyaml
    root
    qcdnum
    gsl
    yaml-cpp
    zlib
  ]
  ++ lib.optional (stdenv.hostPlatform.libc == "glibc") libtirpc;

  env = lib.optionalAttrs (stdenv.hostPlatform.libc == "glibc") {
    NIX_CFLAGS_COMPILE = "-I${libtirpc.dev}/include/tirpc";
    NIX_LDFLAGS = "-ltirpc";
  };

  preConfigure = ''
    substituteInPlace "CMakeLists.txt" \
      --replace-fail 'cmake_minimum_required(VERSION 2.8.12.2)' \
                     'cmake_minimum_required(VERSION 3.10)'
  '';

  # workaround wrong library IDs
  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    ln -sv "$out/lib/xfitter/"* "$out/lib/"
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Open source QCD fit framework designed to extract PDFs and assess the impact of new data";
    homepage = "https://www.xfitter.org/xFitter";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ veprbl ];
    platforms = lib.platforms.unix;
  };
}
