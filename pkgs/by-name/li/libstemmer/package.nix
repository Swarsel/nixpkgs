{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libstemmer";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "snowballstem";
    repo = "snowball";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-qXrypwv/I+5npvGHGsHveijoui0ZnoGYhskCfLkewVE=";
  };

  nativeBuildInputs = [ perl ];

  installPhase = ''
    runHook preInstall
    install -Dt $out/lib libstemmer.a
    install -Dt $out/include include/libstemmer.h
    install -Dt $out/bin {snowball,stemwords}
    runHook postInstall
  '';

  makeTarget = "libstemmer.a";

  prePatch = ''
    patchShebangs .
  ''
  + lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace GNUmakefile \
      --replace './snowball' '${lib.getBin buildPackages.libstemmer}/bin/snowball'
  '';

  meta = {
    description = "Snowball Stemming Algorithms";
    homepage = "https://snowballstem.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.all;
  };
})
