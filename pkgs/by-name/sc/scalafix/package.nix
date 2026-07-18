{
  lib,
  stdenv,
  coursier,
  installShellFiles,
  jre8,
  makeWrapper,
  setJavaClassPath,
  testers,
}:
let
  jre = jre8; # TODO: remove override https://github.com/NixOS/nixpkgs/pull/89731
in
stdenv.mkDerivation (finalAttrs: {
  pname = "scalafix";
  version = "0.12.0";

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
    setJavaClassPath
  ];

  buildInputs = [ finalAttrs.deps ];

  installPhase = ''
    makeWrapper ${jre}/bin/java $out/bin/${finalAttrs.pname} \
      --add-flags "-cp $CLASSPATH scalafix.cli.Cli"

    installShellCompletion --cmd ${finalAttrs.pname} \
      --bash <($out/bin/${finalAttrs.pname} --bash) \
      --zsh  <($out/bin/${finalAttrs.pname} --zsh)
  '';

  deps = stdenv.mkDerivation {
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/cs fetch ch.epfl.scala:scalafix-cli_2.13.13:${finalAttrs.version} > deps
      mkdir -p $out/share/java
      cp $(< deps) $out/share/java/
    '';

    name = "${finalAttrs.pname}-deps-${finalAttrs.version}";
    outputHash = "sha256-HMTnr3awTIAgLSl4eF36U1kv162ajJxC5MreSk2TfUE=";
    outputHashMode = "recursive";
  };

  dontUnpack = true;

  passthru.tests = {
    testVersion = testers.testVersion {
      version = "${finalAttrs.version}";
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Refactoring and linting tool for Scala";
    homepage = "https://scalacenter.github.io/scalafix/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.tomahna ];
    mainProgram = "scalafix";
  };
})
