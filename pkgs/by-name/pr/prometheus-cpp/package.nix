{
  lib,
  stdenv,
  fetchFromGitHub,
  civetweb,
  cmake,
  curl,
  gbenchmark,
  gtest,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prometheus-cpp";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "jupp0r";
    repo = "prometheus-cpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XQ8N+affKVqn/hrMHWg0eN+0Op6m9ZdVNNAW0GpDAng=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gbenchmark
    gtest
  ];

  propagatedBuildInputs = [
    civetweb
    curl
    zlib
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DOVERRIDE_CXX_STANDARD_FLAGS=OFF"
    "-DUSE_THIRDPARTY_LIBRARIES=OFF"
  ];

  meta = {
    description = "Prometheus Client Library for Modern C++";
    homepage = "https://github.com/jupp0r/prometheus-cpp";
    license = [ lib.licenses.mit ];
  };
})
