{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  ronn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flock";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "discoteq";
    repo = "flock";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-cCpckORtogs6Nt7c5q2+z0acXAnALdLV6uzxa5ng3s4=";
  };

  patches = [
    (fetchpatch {
      name = "fix-format-specifier.patch";
      sha256 = "sha256-YuFKXWTBu9A2kBNqkg1Oek6vDbVo/y8dB1k9Fuh3QmA";
      url = "https://github.com/discoteq/flock/commit/408bad42eb8d76cdd0c504c2f97f21c0b424c3b1.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    ronn
  ];

  meta = {
    description = "Cross-platform version of flock(1)";
    homepage = "https://github.com/discoteq/flock";
    license = lib.licenses.isc;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "flock";
  };
})
