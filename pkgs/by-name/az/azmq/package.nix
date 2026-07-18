{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  catch2,
  cmake,
  ninja,
  unstableGitUpdater,
  zeromq,
}:

stdenv.mkDerivation {
  pname = "azmq";
  version = "1.0.3-unstable-2025-11-30";

  src = fetchFromGitHub {
    owner = "zeromq";
    repo = "azmq";
    rev = "819b24035cfa5b73081e21f5867445f2344f680d";
    hash = "sha256-jOdggbO+A0ituGmhdpvvBGGNmudmdVlbUJJzEpXILVE=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    boost
    catch2
    zeromq
  ];

  # Broken for some reason on this platform.
  doCheck = !(stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux);

  passthru.updateScript = unstableGitUpdater {
    tagPrefix = "v";
  };

  meta = {
    description = "C++ language binding library integrating ZeroMQ with Boost Asio";
    homepage = "https://github.com/zeromq/azmq";
    license = lib.licenses.boost;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
