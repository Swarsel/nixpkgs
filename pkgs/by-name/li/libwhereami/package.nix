{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  curl,
  leatherman,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libwhereami";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "puppetlabs";
    repo = "libwhereami";
    rev = finalAttrs.version;
    sha256 = "05fc28dri2h858kxbvldk5b6wd5is3fjcdsiqj3nxf95i66bb3xp";
  };

  # CMake 2.2.2 is deprecated and no longer supported by CMake > 4
  # https://github.com/NixOS/nixpkgs/issues/445447
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required(VERSION 3.2.2)" \
      "cmake_minimum_required(VERSION 3.10)"

    # boost 1.89 removed the boost_system stub library
    substituteInPlace CMakeLists.txt --replace-fail \
      'list(APPEND BOOST_COMPONENTS filesystem regex system thread)' \
      'list(APPEND BOOST_COMPONENTS filesystem regex thread)'
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    curl
    leatherman
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Library to report hypervisor information from inside a VM";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.womfoo ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ]; # fails on aarch64
  };

})
