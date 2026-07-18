{
  lib,
  stdenv,
  fetchFromGitHub,
  asio_1_32_0,
  catch2,
  cmake,
  fetchpatch,
  git,
  spdlog,
  udev,
}:

stdenv.mkDerivation rec {
  pname = "pc-ble-driver";
  version = "4.1.4";

  src = fetchFromGitHub {
    owner = "NordicSemiconductor";
    repo = "pc-ble-driver";
    rev = "v${version}";
    hash = "sha256-srH7Gdiy9Lsv68fst/9jhifx03R2e+4kMia6pU/oCZg=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-bvK1BXjdlhIXV8R4PiCGaq8oSLzgjMmTgAwssm8N2sk=";
      name = "support-arm.patch";
      url = "https://github.com/NordicSemiconductor/pc-ble-driver/commit/76a6b31dba7a13ceae40587494cbfa01a29192f4.patch";
    })
    # Fix build with GCC 11
    (fetchpatch {
      hash = "sha256-gOdzIW8YJQC+PE4FJd644I1+I7CMcBY8wpF6g02eI5g=";
      url = "https://github.com/NordicSemiconductor/pc-ble-driver/commit/37258e65bdbcd0b4369ae448faf650dd181816ec.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    git
  ];

  buildInputs = [
    # Depends on io_service
    asio_1_32_0
    catch2
    spdlog
  ];

  propagatedBuildInputs = [

  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    udev
  ];

  cmakeFlags = [
    "-DNRF_BLE_DRIVER_VERSION=${version}"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    "-DARCH=arm64"
  ];

  meta = {
    description = "Desktop library for Bluetooth low energy development";
    homepage = "https://github.com/NordicSemiconductor/pc-ble-driver";
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.unix;
  };
}
