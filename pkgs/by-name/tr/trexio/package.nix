{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  emacs,
  gfortran,
  hdf5,
  python3,
  swig,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "trexio";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "TREX-CoE";
    repo = "trexio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-iESt7dXta/Enpgb418js26y5+YvROsqgxvNhgAgXd/I=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs tools/*
  '';

  nativeBuildInputs = [
    cmake
    gfortran
    emacs
    swig
    python3
  ];

  buildInputs = [
    hdf5
  ];

  doCheck = true;

  meta = {
    description = "File format and library for the storage of quantum chemical wave functions";
    homepage = "https://trex-coe.github.io/trexio/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.sheepforce ];
    downloadPage = "https://github.com/TREX-CoE/trexio";
  };
})
