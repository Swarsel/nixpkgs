{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  hackrf,
  pkg-config,
  soapysdr,
}:

let
  version = "0.3.4";

in
stdenv.mkDerivation {
  inherit version;
  pname = "soapyhackrf";

  src = fetchFromGitHub {
    owner = "pothosware";
    repo = "SoapyHackRF";
    rev = "soapy-hackrf-${version}";
    sha256 = "sha256-fzPYHJAPX8FkFxPXpLlUagTd/NoamRX0YnxHwkbV1nI=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-8tMN6uEWUt1sUC45kBM6WHXDd/oTFyo6u+NpVPg+z5Q=";
      url = "https://github.com/pothosware/SoapyHackRF/commit/143ff5e7e0f786e341df8846c04e8273c5183c26.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    hackrf
    soapysdr
  ];

  cmakeFlags = [ "-DSoapySDR_DIR=${soapysdr}/share/cmake/SoapySDR/" ];

  meta = {
    description = "SoapySDR plugin for HackRF devices";
    homepage = "https://github.com/pothosware/SoapyHackRF";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ markuskowa ];
    platforms = lib.platforms.unix;
  };
}
