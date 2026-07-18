{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  fftwFloat,
  libbladeRF,
  libconfig,
  lksctp-tools,
  mbedtls,
  pcsclite,
  pkg-config,
  soapysdr-with-plugins,
  uhd,
  zeromq,
  enableAvx ? stdenv.hostPlatform.avxSupport,
  enableAvx2 ? stdenv.hostPlatform.avx2Support,
  enableAvx512 ? stdenv.hostPlatform.avx512Support,
  enableFma ? stdenv.hostPlatform.fmaSupport,
  enableLteRates ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "srsran";
  version = "25_10";

  src = fetchFromGitHub {
    owner = "srsran";
    repo = "srsRAN_4G";
    tag = "release_${builtins.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    sha256 = "sha256-DwQ4u17m8D5RqX3OIYSyeE5+51sLah1qchRcwlX5i0A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  # boost 1.89 removed the boost_system stub library
  postPatch = ''
    substituteInPlace cmake/modules/FindUHD.cmake --replace-fail \
      'set(CMAKE_REQUIRED_LIBRARIES uhd boost_program_options boost_system)' \
      'set(CMAKE_REQUIRED_LIBRARIES uhd boost_program_options)'
    substituteInPlace lib/src/phy/rf/CMakeLists.txt --replace-fail \
      '/usr/lib/x86_64-linux-gnu/libboost_system.so' ""
    substituteInPlace CMakeLists.txt --replace-fail \
      'list(APPEND BOOST_REQUIRED_COMPONENTS "system")' ""
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    fftwFloat
    mbedtls
    boost
    libconfig
    lksctp-tools
    pcsclite
    uhd
    soapysdr-with-plugins
    libbladeRF
    zeromq
  ];

  cmakeFlags = [
    "-DENABLE_WERROR=OFF"
    (lib.cmakeBool "USE_LTE_RATES" enableLteRates)
    (lib.cmakeBool "ENABLE_AVX" enableAvx)
    (lib.cmakeBool "ENABLE_AVX2" enableAvx2)
    (lib.cmakeBool "ENABLE_FMA" enableFma)
    (lib.cmakeBool "ENABLE_AVX512" enableAvx512)
  ];

  postInstall = lib.optionalString (!stdenv.hostPlatform.isStatic) ''
    rm $out/lib/*.a
  '';

  __structuredAttrs = true;

  meta = {
    description = "Open-source 4G software radio suite, including complete LTE UE, eNodeB and EPC applications";
    homepage = "https://www.srslte.com/";
    changelog = "https://github.com/srsran/srsRAN_4G/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      hexagonal-sun
      felbinger
    ];

    platforms = lib.platforms.linux;
  };
})
