{
  lib,
  stdenv,
  fetchurl,
  ant,
  callPackage,
  jdk8,
  makeWrapper,
  stripJavaArchivesHook,
  unzip,
}:

let
  jdk = jdk8;
  jre = jdk8.jre;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "jasmin";
  version = "2.4";

  src = fetchurl {
    url = "mirror://sourceforge/jasmin/jasmin-${finalAttrs.version}.zip";
    hash = "sha256-6qEMaM7Gggb9EC6exxE3OezNeQEIoblabow+k/IORJ0=";
  };

  nativeBuildInputs = [
    unzip
    ant
    jdk
    makeWrapper
    stripJavaArchivesHook
  ];

  buildPhase = ''
    runHook preBuild
    ant all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 jasmin.jar $out/share/java/jasmin.jar
    makeWrapper ${jre}/bin/java $out/bin/jasmin \
      --add-flags "-jar $out/share/java/jasmin.jar"

    runHook postInstall
  '';

  passthru.tests = {
    minimal-module = callPackage ./test-assemble-hello-world { };
  };

  meta = {
    description = "Assembler for the Java Virtual Machine";
    homepage = "https://jasmin.sourceforge.net/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.all;
    mainProgram = "jasmin";
    downloadPage = "https://sourceforge.net/projects/jasmin/files/latest/download";
  };
})
