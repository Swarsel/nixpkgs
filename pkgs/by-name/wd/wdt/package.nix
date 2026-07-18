{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  double-conversion,
  folly,
  gflags,
  glog,
  openssl,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "wdt";
  version = "1.27.1612021-unstable-2026-06-26";

  src = fetchFromGitHub {
    owner = "facebook";
    repo = "wdt";
    rev = "ee01f20850558d5c6a0e1fc3cf9d12cd1702c18a";
    hash = "sha256-YReA7lBSeWRZHpF4E7yY6HuabRUOT6Aipk9dgjlTuik=";
  };

  patches = [
    ./fix-glog-include.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.2)" "cmake_minimum_required(VERSION 3.10)" \
      --replace-fail "find_package(Boost COMPONENTS system filesystem REQUIRED)" \
        "find_package(Boost COMPONENTS filesystem REQUIRED)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    folly
    gflags
    glog
    openssl
    double-conversion
  ];

  cmakeFlags = [
    "-DWDT_USE_SYSTEM_FOLLY=ON"
  ];

  # source is expected to be named wdt
  # https://github.com/facebook/wdt/blob/43319e59d0c77092468367cdadab37d12d7a2383/CMakeLists.txt#L238
  postUnpack = ''
    ln -s $sourceRoot wdt
  '';

  passthru = {
    updateScript = unstableGitUpdater {
      tagPrefix = "v";
    };
  };

  meta = {
    description = "Warp speed Data Transfer";
    homepage = "https://github.com/facebook/wdt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = [ "x86_64-linux" ];
  };
}
