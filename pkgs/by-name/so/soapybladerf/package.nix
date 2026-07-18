{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libbladeRF,
  pkg-config,
  soapysdr,
}:

let
  version = "0.4.2";

in
stdenv.mkDerivation {
  inherit version;
  pname = "soapybladerf";

  src = fetchFromGitHub {
    owner = "pothosware";
    repo = "SoapyBladeRF";
    rev = "soapy-bladerf-${version}";
    sha256 = "sha256-lhTiu+iCdlLTY5ceND+F8HzKf2K9afuTi3cme6nGEMo=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-szqHbSAHiK0F83bxYnrblEBi/U7tpD0AXotYV1eTFxU=";
      url = "https://github.com/pothosware/SoapyBladeRF/commit/f141b61624f24a56aa3bdf7b0cc61c9fa65c26a3.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libbladeRF
    soapysdr
  ];

  cmakeFlags = [ "-DSoapySDR_DIR=${soapysdr}/share/cmake/SoapySDR/" ];

  meta = {
    description = "SoapySDR plugin for BladeRF devices";
    homepage = "https://github.com/pothosware/SoapyBladeRF";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.unix;
  };
}
