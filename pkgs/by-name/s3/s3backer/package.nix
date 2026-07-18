{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  expat,
  fuse3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "s3backer";
  version = "2.1.6";

  src = fetchFromGitHub {
    owner = "archiecobbs";
    repo = "s3backer";
    tag = finalAttrs.version;
    hash = "sha256-bSqkgNZFevtxyaJwoVRcWWO6ZA/Ekbp2gwSJNBmjHwI=";
  };

  # AC_CHECK_DECLS doesn't work with clang
  postPatch = lib.optionalString stdenv.cc.isClang ''
    substituteInPlace configure.ac --replace-fail \
      'AC_CHECK_DECLS(fdatasync)' ""
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    fuse3
    curl
    expat
  ];

  env.CFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-DFUSE_DARWIN_ENABLE_EXTENSIONS=0";

  meta = {
    description = "FUSE-based single file backing store via Amazon S3";
    homepage = "https://github.com/archiecobbs/s3backer";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "s3backer";
  };
})
