{
  lib,
  stdenv,
  autoreconfHook,
  fetchgit,
  libelf,
  libiberty,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "prelink";
  version = "20151030-unstable-2024-07-02";

  src = fetchgit {
    url = "https://git.yoctoproject.org/prelink-cross";
    rev = "ff2561c02ade96c5d4d56ddd4e27ff064840a176";
    sha256 = "sha256-wmX7ybrZDWEop9fiInZMvgK/fpEk3sq+Wu8DSWWIvQY=";
    branchName = "cross_prelink";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    stdenv.cc.libc
    libelf
    libiberty
  ];

  # most tests fail
  doCheck = false;

  configurePlatforms = [
    "build"
    "host"
  ];

  enableParallelBuilding = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "ELF prelinking utility to speed up dynamic linking";
    homepage = "https://wiki.yoctoproject.org/wiki/Cross-Prelink";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.linux;
  };
}
