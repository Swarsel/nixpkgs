{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  libpcap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "usbtop";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "aguinet";
    repo = "usbtop";
    tag = "release-${finalAttrs.version}";
    hash = "sha256-Ws90l5C+KzQC5QgbX7+Hv/Fw5lRAGQoSzJJIgxVoamE=";
  };

  postPatch =
    # fix compatibility with CMake (https://cmake.org/cmake/help/v4.0/command/cmake_minimum_required.html)
    # TODO: drop when https://github.com/aguinet/usbtop/pull/45 is merged
    ''
      substituteInPlace CMakeLists.txt \
        --replace-fail \
          'cmake_minimum_required(VERSION 2.8)' \
          'cmake_minimum_required(VERSION 2.8...4.0)'
    '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libpcap
    boost
  ];

  meta = {
    description = "Top utility that shows an estimated instantaneous bandwidth on USB buses and devices";
    homepage = "https://github.com/aguinet/usbtop";
    changelog = "https://github.com/aguinet/usbtop/raw/${finalAttrs.src.rev}/CHANGELOG";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "usbtop";
  };
})
