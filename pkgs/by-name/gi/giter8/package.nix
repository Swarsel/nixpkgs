{
  lib,
  stdenv,
  coursier,
  giter8,
  jre,
  makeWrapper,
  setJavaClassPath,
  testers,
}:

let
  pname = "giter8";
  version = "0.18.0";
  deps = stdenv.mkDerivation {
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/cs fetch org.foundweekends.giter8:giter8_2.13:${version} > deps
      mkdir -p $out/share/java
      cp $(< deps) $out/share/java/
    '';

    name = "${pname}-deps-${version}";
    outputHash = "sha256-MrFuyktyXADZ8lh/vzpVNi12IbKjM/Q8P7X8EE4KFNo=";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit pname version;
  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    setJavaClassPath
  ];

  buildInputs = [ deps ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${jre}/bin/java $out/bin/g8 \
      --add-flags "-cp $CLASSPATH giter8.Giter8"

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/g8 --version | grep -q "${version}"
  '';

  __structuredAttrs = true;
  dontUnpack = true;

  passthru.tests.version = testers.testVersion {
    command = "g8 --version";
    package = giter8;
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "A command line tool to apply templates defined on GitHub";
    homepage = "https://www.foundweekends.org/giter8/";
    changelog = "https://github.com/foundweekends/giter8/releases/tag/v${version}";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.agilesteel ];
    mainProgram = "g8";
  };
}
