{
  lib,
  fetchurl,
  jdk25_headless,
  makeWrapper,
  maven,
  stdenvNoCC,
  testers,
}:
let
  # Maven 4 defaults to the latest LTS JDK. Bump this binding to change it.
  jdk_headless = jdk25_headless;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "maven";
  version = "4.0.0-rc-5";

  src = fetchurl {
    url = "mirror://apache/maven/maven-4/${finalAttrs.version}/binaries/apache-maven-${finalAttrs.version}-bin.tar.gz";
    hash = "sha256-7OalyZ09BBx25/7RgU656jogoSC8s8I1pz0sTo2xbKE=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/maven
    cp -r apache-maven-${finalAttrs.version}/* $out/maven

    makeWrapper $out/maven/bin/mvn $out/bin/mvn \
      --set-default JAVA_HOME "${jdk_headless}"
    makeWrapper $out/maven/bin/mvnDebug $out/bin/mvnDebug \
      --set-default JAVA_HOME "${jdk_headless}"

    runHook postInstall
  '';

  __structuredAttrs = true;
  sourceRoot = ".";

  passthru = {
    # Reuse maven's builder so build-maven-package.nix is not duplicated.
    buildMavenPackage = maven.mkBuildMavenPackage finalAttrs.finalPackage;

    tests = {
      version = testers.testVersion {
        command = ''
          env MAVEN_OPTS="-Dmaven.repo.local=$TMPDIR/m2" \
            mvn --version
        '';

        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    inherit (jdk_headless.meta) platforms;
    description = "Build automation tool (used primarily for Java projects)";

    longDescription = ''
      Apache Maven is a software project management and comprehension
      tool. Based on the concept of a project object model (POM), Maven can
      manage a project's build, reporting and documentation from a central piece
      of information.
    '';

    homepage = "https://maven.apache.org/";
    changelog = "https://maven.apache.org/docs/${finalAttrs.version}/release-notes.html";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [
      tricktron
      britter
    ];

    mainProgram = "mvn";
    teams = [ lib.teams.java ];
  };
})
