{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchzip,
  fftw,
  fftwFloat,
  llvmPackages,
  enablePython ? false,
  pythonPackages ? null,
}:
let
  # CMake recipes are needed to build galario
  # Build process would usually download them
  great-cmake-cookoff = fetchzip {
    hash = "sha256-ggMcgKfpYHWWgyYY84u4Q79IGCVTVkmIMw+N/soapfk=";
    url = "https://github.com/UCL/GreatCMakeCookOff/archive/v2.1.9.tar.gz";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "galario";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "mtazzari";
    repo = "galario";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QMHtL9155VNphMKI1/Z7WUVIvyI2K/ac53J0UNRDiDc=";
  };

  postPatch = ''
    substituteInPlace python/utils.py \
      --replace-fail "trapz" "trapezoid" \
      --replace-fail "np.int" "int"

    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    fftw
    fftwFloat
  ]
  ++ lib.optional enablePython pythonPackages.python
  ++ lib.optional stdenv.hostPlatform.isDarwin llvmPackages.openmp;

  propagatedBuildInputs = lib.optionals enablePython [
    pythonPackages.numpy
    pythonPackages.cython_0
    pythonPackages.distutils
    pythonPackages.pytest
  ];

  cmakeFlags = lib.optionals enablePython [
    # RPATH of binary /nix/store/.../lib/python3.10/site-packages/galario/double/libcommon.so contains a forbidden reference to /build/
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  preConfigure = ''
    mkdir -p build/external/src
    cp -r ${great-cmake-cookoff} build/external/src/GreatCMakeCookOff
    chmod -R 777 build/external/src/GreatCMakeCookOff
  '';

  doCheck = true;

  nativeCheckInputs = lib.optionals enablePython [
    pythonPackages.scipy
    pythonPackages.pytest-cov
  ];

  preCheck = ''
    ${
      if stdenv.hostPlatform.isDarwin then
        "export DYLD_LIBRARY_PATH=$(pwd)/src/"
      else
        "export LD_LIBRARY_PATH=$(pwd)/src/"
    }
    ${lib.optionalString enablePython "sed -i -e 's|^#!.*|#!${stdenv.shell}|' python/py.test.sh"}
  '';

  postInstall = lib.optionalString (stdenv.hostPlatform.isDarwin && enablePython) ''
    install_name_tool -change libgalario.dylib $out/lib/libgalario.dylib $out/lib/python*/site-packages/galario/double/libcommon.so
    install_name_tool -change libgalario_single.dylib $out/lib/libgalario_single.dylib $out/lib/python*/site-packages/galario/single/libcommon.so
  '';

  meta = {
    description = "GPU Accelerated Library for Analysing Radio Interferometer Observations";

    longDescription = ''
      Galario is a library that exploits the computing power of modern
      graphic cards (GPUs) to accelerate the comparison of model
      predictions to radio interferometer observations. Namely, it
      speeds up the computation of the synthetic visibilities given a
      model image (or an axisymmetric brightness profile) and their
      comparison to the observations.
    '';

    homepage = "https://mtazzari.github.io/galario/";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.smaret ];
    platforms = lib.platforms.all;
  };
})
