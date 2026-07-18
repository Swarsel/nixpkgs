{
  lib,
  fetchFromGitHub,
  boost,
  cmake,
  fftw,
  fftwFloat,
  gccStdenv,
  ocl-icd,
  opencl-clhpp,
}:

let
  stdenv = gccStdenv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "clfft";
  version = "2.12.2";

  src = fetchFromGitHub {
    owner = "clMathLibraries";
    repo = "clFFT";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yp7u6qhpPYQpBw3d+VLg0GgMyZONVII8BsBCEoRZm4w=";
  };

  postPatch = ''
    sed -i '/-m64/d;/-m32/d' CMakeLists.txt
    substituteInPlace CMakeLists.txt --replace-fail \
      'cmake_minimum_required( VERSION 2.6 )' \
      'cmake_minimum_required( VERSION 3.5 ) '
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    fftw
    fftwFloat
    boost
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    opencl-clhpp
    ocl-icd
  ];

  # https://github.com/clMathLibraries/clFFT/issues/237
  env.CXXFLAGS = "-std=c++98";
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Library containing FFT functions written in OpenCL";

    longDescription = ''
      clFFT is a software library containing FFT functions written in OpenCL.
      In addition to GPU devices, the library also supports running on CPU devices to facilitate debugging and heterogeneous programming.
    '';

    homepage = "http://clmathlibraries.github.io/clFFT/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chessai ];
    platforms = lib.platforms.unix;
  };
})
