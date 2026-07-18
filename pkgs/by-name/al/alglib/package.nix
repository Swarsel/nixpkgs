{
  lib,
  stdenv,
  fetchurl,
  clang,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "alglib3";
  version = "4.08.0";

  src = fetchurl {
    url = "https://www.alglib.net/translator/re/alglib-${finalAttrs.version}.cpp.gpl.tgz";
    sha256 = "sha256-mKPtCE+wLFagvBVDida8oQCyO7N0klWkyHFjkip3aoY=";
  };

  patches = [
    ./patch-alglib-CMakeLists.patch
  ];

  nativeBuildInputs = [
    cmake
    clang
  ];

  meta = {
    description = "Numerical analysis and data processing library";

    longDescription = ''
      ALGLIB is a cross-platform numerical analysis and data processing library. It supports several programming languages (C++, C#, Delphi) and several operating systems (Windows and POSIX, including Linux). ALGLIB features include:

      * Data analysis (classification/regression, statistics)
      * Optimization and nonlinear solvers
      * Interpolation and linear/nonlinear least-squares fitting
      * Linear algebra (direct algorithms, EVD/SVD), direct and iterative linear solvers
      * Fast Fourier Transform and many other algorithms
    '';

    homepage = "https://www.alglib.net/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.paperdigits ];
  };
})
