{
  lib,
  stdenv,
  fetchurl,
  fetchFromSourcehut,
  gv,
  installShellFiles,
  makeBinaryWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "klong";
  version = "20221212";

  src = fetchurl {
    url = "https://t3x.org/klong/klong${finalAttrs.version}.tgz";
    hash = "sha256-XhpIdyKKPGQ6mdv9LXPmC8P6hW4mFawv54yANw5/lrQ=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall
    install -m 555 -Dt $out/bin kg kplot
    install -m 444 -Dt $out/lib/klong lib/*.kg
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/kg --prefix KLONGPATH : $out/lib/klong
    wrapProgram $out/bin/kplot --prefix PATH : ${
      lib.makeBinPath [
        "$out"
        gv
      ]
    }
    installManPage $docs/*.1
  '';

  docs = fetchFromSourcehut {
    hash = "sha256-yfvXljjJwCETWPa70zXhaQJOHhZYR2k+BKAd0Dw/U70=";
    owner = "~nut";
    repo = "klong-docs";
    rev = "350da558709e3728df60ddf45fafe09e3fb89139";
  };

  meta = {
    description = "Simple Array programming language";
    homepage = "https://t3x.org/klong";

    license = with lib.licenses; [
      publicDomain
      cc0
    ];

    maintainers = [ lib.maintainers.casaca ];
    platforms = lib.platforms.all;
    mainProgram = "kg";
  };
})
