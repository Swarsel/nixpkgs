{
  lib,
  stdenv,
  coursier,
  jre,
  makeWrapper,
  setJavaClassPath,
}:

let
  baseName = "scalafmt";
  version = "3.11.1";
  deps = stdenv.mkDerivation {
    buildCommand = ''
      export COURSIER_CACHE=$(pwd)
      ${coursier}/bin/cs fetch org.scalameta:scalafmt-cli_2.13:${version} > deps
      mkdir -p $out/share/java
      cp $(< deps) $out/share/java/
    '';

    name = "${baseName}-deps-${version}";
    outputHash = "sha256-EgkXDCbgn7OmH1e/us6lyNiei/qZMzFn/1Qh4LiraBo=";
    outputHashMode = "recursive";
  };
in
stdenv.mkDerivation {
  inherit version;
  pname = baseName;

  nativeBuildInputs = [
    makeWrapper
    setJavaClassPath
  ];

  buildInputs = [ deps ];

  installPhase = ''
    runHook preInstall

    makeWrapper ${jre}/bin/java $out/bin/${baseName} \
      --add-flags "-cp $CLASSPATH org.scalafmt.cli.Cli"

    runHook postInstall
  '';

  installCheckPhase = ''
    $out/bin/${baseName} --version | grep -q "${version}"
  '';

  dontUnpack = true;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Opinionated code formatter for Scala";
    homepage = "http://scalameta.org/scalafmt";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.markus1189 ];
    mainProgram = "scalafmt";
  };
}
