{
  lib,
  stdenv,
  fetchFromGitHub,
  amd-blis,
  aocl-utils,
  cmake,
  gfortran,
  python3,
  blas64 ? false,
  withAMDOpt ? true,
  withOpenMP ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amd-libflame";
  version = "5.1";

  src = fetchFromGitHub {
    owner = "amd";
    repo = "libflame";
    tag = finalAttrs.version;
    hash = "sha256-9Z0e6RCJfqQlq3oT4fBu8rwPH1OWEKQ52rVDa0Y0rJU=";
  };

  postPatch = ''
    patchShebangs build

    # Enforce reproducible build compiler flags
    substituteInPlace CMakeLists.txt --replace '-mtune=native' ""
  '';

  nativeBuildInputs = [
    cmake
    gfortran
    python3
  ];

  buildInputs = [
    amd-blis
    aocl-utils
  ];

  cmakeFlags = [
    "-DLIBAOCLUTILS_LIBRARY_PATH=${lib.getLib aocl-utils}/lib/libaoclutils${stdenv.hostPlatform.extensions.sharedLibrary}"
    "-DLIBAOCLUTILS_INCLUDE_PATH=${lib.getDev aocl-utils}/include"
    "-DENABLE_BUILTIN_LAPACK2FLAME=ON"
    "-DENABLE_CBLAS_INTERFACES=ON"
    "-DENABLE_EXT_LAPACK_INTERFACE=ON"
  ]
  ++ lib.optional (!withOpenMP) "-DENABLE_MULTITHREADING=OFF"
  ++ lib.optional blas64 "-DENABLE_ILP64=ON"
  ++ lib.optional withAMDOpt "-DENABLE_AMD_OPT=ON";

  env.NIX_CFLAGS_COMPILE = "-Wno-implicit-function-declaration";

  postInstall = ''
    ln -s $out/lib/libflame.so $out/lib/liblapack.so.3
    ln -s $out/lib/libflame.so $out/lib/liblapacke.so.3
  '';

  passthru = {
    inherit blas64;
  };

  meta = {
    description = "LAPACK-compatible linear algebra library optimized for AMD CPUs";
    homepage = "https://developer.amd.com/amd-aocl/blas-library/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
})
