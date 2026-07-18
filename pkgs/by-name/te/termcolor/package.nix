{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "termcolor";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ikalnytskyi";
    repo = "termcolor";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-2RXQ8sn2VNhQ2WZfwCCeQuM6x6C+sLA6ulAaFtaDMZw=";
  };

  patches = [
    # bump minimal required cmake version
    (fetchpatch {
      hash = "sha256-xouiacA+Kpjz+KOw6PgNRCXHAMENiqMww2WTvAvUpCE=";
      url = "https://github.com/ikalnytskyi/termcolor/commit/89f20096bef51de347ec6f99345f65147359bd7c.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [ cmake ];
  cmakeFlags = [ "-DTERMCOLOR_TESTS=ON" ];

  env.CXXFLAGS = toString [
    # GCC 13: error: 'uint8_t' has not been declared
    "-include cstdint"
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    ./test_termcolor
    runHook postCheck
  '';

  meta = {
    description = "Header-only C++ library for printing colored messages";
    homepage = "https://github.com/ikalnytskyi/termcolor";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ prusnak ];
    platforms = lib.platforms.unix;
  };
})
