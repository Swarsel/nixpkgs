{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  gmp,
  mpfr,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "scipopt-soplex";
  version = "8.0.2";

  src = fetchFromGitHub {
    owner = "scipopt";
    repo = "soplex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TW3OSBw8ok64kZedsXYjkO2eFqr0LH8uvrOsi3bwQC4=";
  };

  strictDeps = true;
  nativeBuildInputs = [ cmake ];

  buildInputs = [
    boost
    gmp
    mpfr
    zlib
  ];

  doCheck = true;

  meta = {
    description = "Sequential object-oriented simPlex";
    homepage = "https://soplex.zib.de/";
    changelog = "https://soplex.zib.de/doc-${finalAttrs.version}/html/CHANGELOG.php";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ pmeinhold ];
    platforms = lib.platforms.unix;
    mainProgram = "soplex";
  };
})
