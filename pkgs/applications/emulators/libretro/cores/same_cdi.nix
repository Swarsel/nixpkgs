{
  lib,
  fetchFromGitHub,
  alsa-lib,
  fetchpatch2,
  libGL,
  libGLU,
  libx11,
  mkLibretroCore,
  portaudio,
  python3,
}:
mkLibretroCore {
  version = "0-unstable-2026-03-31";

  src = fetchFromGitHub {
    owner = "libretro";
    repo = "same_cdi";
    rev = "2184aa6d87a31fb6c64534b9b7b2d26e36bae757";
    hash = "sha256-8QJtAyVF6KQmWSzQ6t5s4qmSVT8CmRx5uulq4c3LDRo=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-1vrMxnRtEWUt+6I/4PSfCPDIUAGKkXFd2UVr9473ngo=";
      # https://github.com/libretro/same_cdi/pull/19
      name = "Fixes_compilation_errors_as_per_issue_9.patch";
      url = "https://github.com/libretro/same_cdi/commit/bf3212315546cdd514118a4f3ea764fd9c401091.patch?full_index=1";
    })
  ];

  postPatch = ''
    # Fix sol2 compatibility with GCC 15 (construct -> emplace)
    # https://github.com/ThePhD/sol2/issues/1657
    sed -i 's/this->construct(std::forward<Args>(args)\.\.\.);/this->emplace(std::forward<Args>(args)...);/g' 3rdparty/sol2/sol/sol.hpp

    # Fix missing cstdint include for uint8_t
    sed -i '1i #include <cstdint>' src/lib/util/corestr.cpp
  '';

  core = "same_cdi";

  extraBuildInputs = [
    alsa-lib
    libGL
    libGLU
    portaudio
    libx11
  ];

  extraNativeBuildInputs = [ python3 ];

  meta = {
    description = "SAME_CDI is a libretro core to play CD-i games";
    homepage = "https://github.com/libretro/same_cdi";

    license = with lib.licenses; [
      bsd3
      gpl2Plus
    ];
  };
}
