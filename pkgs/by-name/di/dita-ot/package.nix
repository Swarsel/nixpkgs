{
  lib,
  stdenv,
  fetchzip,
  makeWrapper,
  openjdk17,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dita-ot";
  version = "4.4";

  src = fetchzip {
    url = "https://github.com/dita-ot/dita-ot/releases/download/${finalAttrs.version}/dita-ot-${finalAttrs.version}.zip";
    hash = "sha256-0P2E0c5HHOCk1w0/CHe3a6AH8FJIeKoQdTruuGkwo/c=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ openjdk17 ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/dita-ot/
    cp -r $src/* $out/share/dita-ot/

    makeWrapper "$out/share/dita-ot/bin/dita" "$out/bin/dita" \
      --prefix PATH : "${lib.makeBinPath [ openjdk17 ]}" \
      --set-default JDK_HOME "${openjdk17.home}" \
      --set-default JAVA_HOME "${openjdk17.home}"

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "Open-source publishing engine for content authored in the Darwin Information Typing Architecture";
    homepage = "https://dita-ot.org";
    changelog = "https://www.dita-ot.org/dev/release-notes/#v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ robertrichter ];
    platforms = openjdk17.meta.platforms;
    mainProgram = "dita";
  };
})
