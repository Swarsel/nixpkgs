{
  lib,
  stdenv,
  fetchFromGitHub,
  asio,
  boost,
  cmake,
  gperftools,
  hwloc,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hpx";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "TheHPXProject";
    repo = "hpx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-AhByaw1KnEDuRfKiN+/vQMbkG0BJ6Z3+h+QT8scFzAY=";
  };

  patches = [
    # https://github.com/TheHPXProject/hpx/pull/6731
    # Fix build with asio >= 1.34.0
    ./remove_deprecated_asio_features.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    asio
    boost
    gperftools
  ];

  propagatedBuildInputs = [ hwloc ];

  meta = {
    description = "C++ standard library for concurrency and parallelism";
    homepage = "https://github.com/TheHPXProject/hpx";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ bobakker ];
    platforms = [ "x86_64-linux" ]; # lib.platforms.linux;
  };
})
