{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libsndfile,
  libvorbis,
  openal,
  opusfile,
}:

stdenv.mkDerivation {
  pname = "alure2";
  version = "0-unstable-2020-02-06";

  src = fetchFromGitHub {
    owner = "kcat";
    repo = "alure";
    rev = "50f92fe528e77da82197fd947d1cf9b0a82a0c7d";
    sha256 = "1gmc1yfhwaj6lik0vn7zv8y23i05f4rw25v2jg34n856jcs02svx";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    openal
    libvorbis
    opusfile
    libsndfile
  ];

  meta = {
    description = "Utility library for OpenAL, providing a C++ API and managing common tasks that include file loading, caching, and streaming";
    homepage = "https://github.com/kcat/alure";
    license = lib.licenses.zlib;
    maintainers = with lib.maintainers; [ McSinyx ];
    platforms = lib.platforms.linux;
  };
}
