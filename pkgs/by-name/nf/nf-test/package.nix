{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  nextflow,
  nf-test,
  openjdk17,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {

  pname = "nf-test";
  version = "0.9.5";

  src = fetchurl {
    url = "https://github.com/askimed/nf-test/releases/download/v${finalAttrs.version}/nf-test-${finalAttrs.version}.tar.gz";
    hash = "sha256-t2eeuQzclkK/qJ6WNNsCzm5pneU6017w4vSEdjT8FkE=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/nf-test
    install -Dm644 nf-test.jar $out/share/nf-test

    mkdir -p $out/bin
    makeWrapper ${openjdk17}/bin/java $out/bin/nf-test \
      --add-flags "-jar $out/share/nf-test/nf-test.jar" \
      --prefix PATH : ${lib.makeBinPath [ nextflow ]} \

    runHook postInstall
  '';

  sourceRoot = ".";

  passthru.tests.version = testers.testVersion {
    command = "nf-test version";
    package = nf-test;
  };

  meta = {
    description = "Simple test framework for Nextflow pipelines";
    homepage = "https://www.nf-test.com/";
    changelog = "https://github.com/askimed/nf-test/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rollf ];
    platforms = lib.platforms.unix;
    mainProgram = "nf-test";
  };
})
