{
  lib,
  fetchFromGitHub,
  jre,
  makeBinaryWrapper,
  maven,
  nix-update-script,
}:

maven.buildMavenPackage (finalAttrs: {
  pname = "checkstyle";
  version = "13.7.0";

  src = fetchFromGitHub {
    owner = "checkstyle";
    repo = "checkstyle";
    tag = "checkstyle-${finalAttrs.version}";
    hash = "sha256-BrgjkqkVnLYMlouyopUoCTby2z4YWZl4UK7m3Ktm5bE=";
  };

  nativeBuildInputs = [
    maven
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/checkstyle
    install -Dm644 target/checkstyle-${finalAttrs.version}-all.jar $out/share/checkstyle/checkstyle-all.jar

    makeWrapper ${jre}/bin/java $out/bin/checkstyle \
      --add-flags "-jar $out/share/checkstyle/checkstyle-all.jar"

    runHook postInstall
  '';

  mvnHash = "sha256-IKO61ugVjF03zA6pCwYKmwMVx/Ogy8hrt70ArOUm0NA=";
  mvnParameters = lib.escapeShellArgs [ "-Passembly,no-validations" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (jre.meta) platforms;
    description = "Checks Java source against a coding standard";

    longDescription = ''
      checkstyle is a development tool to help programmers write Java code that
      adheres to a coding standard. By default it supports the Sun Code
      Conventions, but is highly configurable.
    '';

    homepage = "https://checkstyle.org/";
    changelog = "https://checkstyle.org/releasenotes.html#Release_${finalAttrs.version}";
    license = lib.licenses.lgpl21;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [
      pSub
      progrm_jarvis
    ];

    mainProgram = "checkstyle";
  };
})
