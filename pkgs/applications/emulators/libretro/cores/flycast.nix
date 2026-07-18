{
  lib,
  fetchFromGitHub,
  cmake,
  libGL,
  libGLU,
  mkLibretroCore,
}:
mkLibretroCore {
  version = "0-unstable-2026-07-10";

  src = fetchFromGitHub {
    owner = "flyinghead";
    repo = "flycast";
    rev = "f09d1f22ef8d199b8b7a2395d0b46774e08a58c2";
    hash = "sha256-labl5MPpBNkg/M95WzJgiKVdvHJDN6jeFSLsHg5+G78=";
    fetchSubmodules = true;
  };

  cmakeFlags = [ "-DLIBRETRO=ON" ];
  core = "flycast";

  extraBuildInputs = [
    libGL
    libGLU
  ];

  extraNativeBuildInputs = [ cmake ];
  makefile = "Makefile";

  meta = {
    description = "Flycast libretro port";
    homepage = "https://github.com/flyinghead/flycast";
    license = lib.licenses.gpl2Only;

    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
