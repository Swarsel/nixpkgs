{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  coeurl,
  curl,
  gtest,
  libevent,
  nlohmann_json,
  olm,
  openssl,
  pkg-config,
  re2,
  spdlog,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mtxclient";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "mtxclient";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Y0FMCq4crSbm0tJtYq04ZFwWw+vlfxXKXBo0XUgf7hw=";
  };

  patches = [
    ./remove-network-tests.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    coeurl
    curl
    libevent
    nlohmann_json
    olm
    openssl
    re2
    spdlog
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_LIB_TESTS" finalAttrs.finalPackage.doCheck)
    (lib.cmakeBool "BUILD_LIB_EXAMPLES" false)
  ];

  doCheck = true;
  checkInputs = [ gtest ];

  meta = {
    description = "Client API library for the Matrix protocol";
    homepage = "https://github.com/Nheko-Reborn/mtxclient";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fpletz
      pstn
      rebmit
      rnhmjoj
    ];

    platforms = lib.platforms.all;
  };
})
