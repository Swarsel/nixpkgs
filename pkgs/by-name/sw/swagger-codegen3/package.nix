{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
  swagger-codegen3,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swagger-codegen";
  version = "3.0.75";

  src = fetchurl {
    url = "mirror://maven/io/swagger/codegen/v3/swagger-codegen-cli/${finalAttrs.version}/swagger-codegen-cli-${finalAttrs.version}.jar";
    hash = "sha256-Na6aWKq1SU/zWfxRf4ZH73lJy/dwbzz7coXP61zFv+E=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D $src $out/share/java/swagger-codegen-cli-${finalAttrs.version}.jar

    makeWrapper ${jre}/bin/java $out/bin/swagger-codegen3 \
      --add-flags "-jar $out/share/java/swagger-codegen-cli-${finalAttrs.version}.jar"

    runHook postInstall
  '';

  dontUnpack = true;

  passthru.tests.version = testers.testVersion {
    command = "swagger-codegen3 version";
    package = swagger-codegen3;
  };

  meta = {
    description = "Allows generation of API client libraries (SDK generation), server stubs and documentation automatically given an OpenAPI Spec";
    homepage = "https://github.com/swagger-api/swagger-codegen/tree/3.0.0";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers._1000101 ];
    platforms = lib.platforms.all;
    mainProgram = "swagger-codegen3";
  };
})
