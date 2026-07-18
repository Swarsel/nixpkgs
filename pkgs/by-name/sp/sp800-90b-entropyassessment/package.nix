{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  jsoncpp,
  libdivsufsort,
  mpfr,
  openssl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sp800-90b-entropyassessment";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "usnistgov";
    repo = "SP800-90B_EntropyAssessment";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qGJqL77IOuVx8jKDdOk4YkLPbggfn+TQtpdcYEu4hC8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "-march=native" "" \
      --replace-fail "-std=c++11" "-std=c++17"
  '';

  buildInputs = [
    bzip2
    libdivsufsort
    jsoncpp
    openssl
    mpfr
  ];

  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    "ARCH=${stdenv.hostPlatform.linuxArch}"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp ea_* $out/bin
    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/cpp";

  meta = {
    description = "Implementation of min-entropy assessment methods included in Special Publication 800-90B";
    homepage = "https://github.com/usnistgov/SP800-90B_EntropyAssessment";
    license = lib.licenses.nistSoftware;

    maintainers = with lib.maintainers; [
      thillux
    ];

    platforms = lib.platforms.linux;
  };
})
