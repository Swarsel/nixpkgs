{
  lib,
  fetchFromGitHub,
  ant,
  cacert,
  git,
  installShellFiles,
  jdk_headless,
  jre_headless,
  makeWrapper,
  pandoc,
  python3,
  stdenvNoCC,
  testers,
}:

let
  pname = "validator-nu";
  version = "25.12.12";

  src = fetchFromGitHub {
    owner = "validator";
    repo = "validator";
    rev = "7ed7f67468f7f61975dcc78891ea462fce578828";
    hash = "sha256-cdDmhRyXIdoNWhP4oqu7vRb5abuNXRqvt4P4Dzq48xY=";
  };

  deps = stdenvNoCC.mkDerivation {
    inherit version src;
    pname = "${pname}-deps";

    postPatch = ''
      substituteInPlace build/build.xml \
        --replace-fail \
        'src="https://html.spec.whatwg.org/"' \
        'src="https://html.spec.whatwg.org/commit-snapshots/0aa021ab4f21a6550f1591a9cc98449aaea9eefa/"'
    '';

    nativeBuildInputs = [
      ant
      cacert
      jdk_headless
      python3
    ];

    buildPhase = ''
      python checker.py dldeps
    '';

    installPhase = ''
      mkdir "$out" "$out/build"
      mv dependencies extras "$out"
      mv build/html5spec "$out/build"
    '';

    outputHash = "sha256-8cMoLeOnKNqisezkVS2UeVW11gtkGmhvQWrbSVuqbb8=";
    outputHashMode = "recursive";
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version src;

  postPatch = ''
    substituteInPlace build/build.py --replace-fail \
      'validatorVersion = "%s.%s.%s" % (year, month, day)' \
      'validatorVersion = "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    ant
    installShellFiles
    jdk_headless
    makeWrapper
    pandoc
    python3
  ];

  buildPhase = ''
    ln -s '${deps}/dependencies' '${deps}/extras' .
    ln -s '${deps}/build/html5spec' build/
    JAVA_HOME='${jdk_headless}' python checker.py --offline build
    make -C docs VNU_VERSION='${finalAttrs.version}' DATE='date -d @$(SOURCE_DATE_EPOCH)'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/share/java"
    mv build/dist/vnu.jar "$out/share/java/"
    installManPage docs/*.1
    makeWrapper "${jre_headless}/bin/java" "$out/bin/vnu" \
      --add-flags "-jar '$out/share/java/vnu.jar'"

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Helps you catch problems in your HTML/CSS/SVG";
    homepage = "https://validator.github.io/validator/";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      fromSource
    ];

    maintainers = with lib.maintainers; [
      andersk
    ];

    platforms = lib.platforms.all;
    mainProgram = "vnu";
  };
})
