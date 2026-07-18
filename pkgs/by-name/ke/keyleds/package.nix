{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libuv,
  libx11,
  libxi,
  libyaml,
  luajit,
  pkg-config,
  udev,
}:

stdenv.mkDerivation {
  pname = "keyleds";
  version = "unstable-2021-04-08";

  src = fetchFromGitHub {
    owner = "keyleds";
    repo = "keyleds";
    rev = "171361654a64b570d747c2d196acb2da4b8dc293";
    sha256 = "sha256-mojgHMT0gni0Po0hiZqQ8eMzqfwUipXue1uqpionihw=";
  };

  # This commit corresponds to the following open PR:
  # https://github.com/keyleds/keyleds/pull/74
  # According to the author of the PR, the maintainer of keyleds is unreachable.
  # This patch fixes the build process which is broken on the current master branch of keyleds.
  patches = [
    (fetchpatch {
      sha256 = "sha256-i2N3D/K++34JVqJloNK2UcN473NarIjdjAz6PUhXcNY=";
      url = "https://github.com/keyleds/keyleds/commit/bffed5eb181127df915002b6ed830f85f15feafd.patch";
    })
  ];

  postPatch = ''
    substituteInPlace {,{keyledsd/plugins,keyledsd,keyledsctl,libkeyleds}/}CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 3.0)" "cmake_minimum_required (VERSION 3.10)"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libuv
    libx11
    libxi
    libyaml
    luajit
    udev
  ];

  cmakeBuildType = "MinSizeRel";
  enableParallelBuilding = true;

  meta = {
    description = "Advanced RGB animation service for Logitech keyboards";
    homepage = "https://github.com/keyleds/keyleds";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
}
