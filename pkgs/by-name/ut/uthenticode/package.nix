{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtest,
  openssl,
  pe-parse,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uthenticode";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "uthenticode";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NGVOGXMRlgpSRw56jr63rJc/5/qCmPjtAFa0D21ogd4=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    pe-parse
    openssl
  ];

  cmakeFlags = [
    "-DBUILD_TESTS=1"
    "-DUSE_EXTERNAL_GTEST=1"
  ];

  doCheck = true;
  nativeCheckInputs = [ gtest ];
  checkPhase = "test/uthenticode_test";

  meta = {
    description = "Small cross-platform library for verifying Authenticode digital signatures";
    homepage = "https://github.com/trailofbits/uthenticode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arturcygan ];
    platforms = lib.platforms.unix;
  };
})
