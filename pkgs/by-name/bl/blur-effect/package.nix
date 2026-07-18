{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gdk-pixbuf,
  libGL,
  libgbm,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blur-effect";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "sonald";
    repo = "blur-effect";
    tag = finalAttrs.version;
    sha256 = "0cjw7iz0p7x1bi4vmwrivfidry5wlkgfgdl9wly88cm3z9ib98jj";
  };

  patches = [
    # Pull cmake-4 fix:
    #   https://github.com/sonald/blur-effect/pull/7
    (fetchpatch {
      hash = "sha256-f0PBhfdrcLCZBzYx+j8+qIG9boW3S4CSyz+bS9vFKRc=";
      name = "cmake-4.patch";
      url = "https://github.com/sonald/blur-effect/commit/76322ad8bd0e653726a6791eb8ebcc829cbb1b38.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    gdk-pixbuf
    libGL
    libgbm
  ];

  meta = {
    description = "Off-screen image blurring utility using OpenGL ES 3.0";
    homepage = "https://github.com/sonald/blur-effect";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "blur_image";
    broken = stdenv.hostPlatform.isDarwin; # packages 'libdrm' and 'gbm' not found
  };
})
