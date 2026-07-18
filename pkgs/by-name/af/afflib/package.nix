{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  expat,
  fuse3,
  openssl,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "afflib";
  version = "3.7.22";

  src = fetchFromGitHub {
    owner = "sshock";
    repo = "AFFLIBv3";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-pGInhJQBhFJhft/KfB3J3S9/BVp9D8TZ+uw2CUNVC+Q=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    zlib
    curl
    expat
    openssl
    python3
    fuse3
  ];

  env.CFLAGS = lib.optionalString stdenv.hostPlatform.isDarwin "-DFUSE_DARWIN_ENABLE_EXTENSIONS=0";

  meta = {
    description = "Advanced forensic format library";
    homepage = "http://afflib.sourceforge.net/";
    license = lib.licenses.bsdOriginal;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
    downloadPage = "https://github.com/sshock/AFFLIBv3/tags";
  };
})
