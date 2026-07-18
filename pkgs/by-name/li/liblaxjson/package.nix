{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liblaxjson";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "andrewrk";
    repo = "liblaxjson";
    rev = finalAttrs.version;
    sha256 = "01iqbpbhnqfifhv82m6hi8190w5sdim4qyrkss7z1zyv3gpchc5s";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Library for parsing JSON config files";
    homepage = "https://github.com/andrewrk/liblaxjson";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
