{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  cmake,
  gst_all_1,
  # for passthru.tests
  imagemagick,
  imlib2Full,
  libheif,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libde265";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "strukturag";
    repo = "libde265";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZHfPC86oylqt2bwWMJRWVjdMEEmX6UOKR7XkR0HPyok=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  enableParallelBuilding = true;

  passthru.tests = {
    inherit imagemagick libheif imlib2Full;
    inherit (gst_all_1) gst-plugins-bad;

    test-corpus-decode = callPackage ./test-corpus-decode.nix {
      libde265 = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Open h.265 video codec implementation";
    homepage = "https://github.com/strukturag/libde265";
    changelog = "https://github.com/strukturag/libde265/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "dec265";
  };
})
