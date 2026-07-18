{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  bash,
  coreutils,
  gradle_8,
  jdk_headless,
  jre,
  nixosTests,
  replaceVars,
  writeText,
}:

let
  gradle = gradle_8;
  jdk = jdk_headless;

  freenet_ext = fetchurl {
    hash = "sha256-MvKz1r7t9UE36i+aPr72dmbXafCWawjNF/19tZuk158=";
    url = "https://github.com/hyphanet/fred/releases/download/build01495/freenet-ext.jar";
  };

  seednodes = fetchFromGitHub {
    hash = "sha256-c04gKNPZtiIdmKmPJ71iXIEXzOoBMw32I2rAsN1+a8Q=";
    name = "freenet-seednodes";
    owner = "hyphanet";

    postFetch = ''
      cat $out/* > $out/seednodes.fref
    '';

    repo = "seedrefs";
    rev = "b34dbc4d021c58c4a108214a71a9e1ab986c4e14";
  };

in
stdenv.mkDerivation rec {
  pname = "freenet";
  version = "01506";

  src = fetchFromGitHub {
    owner = "hyphanet";
    repo = "fred";
    tag = "build${version}";
    hash = "sha256-MmI/e/Sh4WeSSw2//xpmJtF5/oC9+eauXnTMLuojb2A=";
  };

  nativeBuildInputs = [
    gradle
    jdk
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 build/libs/freenet.jar $out/share/freenet/freenet.jar
    ln -s ${freenet_ext} $out/share/freenet/freenet-ext.jar
    mkdir -p $out/bin
    install -Dm755 ${wrapper} $out/bin/freenet
    export CLASSPATH="$(find ${mitmCache} -name "*.jar"| sort | grep -v bcprov-jdk15on-1.48.jar|tr $'\n' :):$out/share/freenet/freenet-ext.jar:$out/share/freenet/freenet.jar"
    substituteInPlace $out/bin/freenet \
      --subst-var-by CLASSPATH "$CLASSPATH"

    runHook postInstall
  '';

  gradleBuildTask = "jar";
  gradleFlags = [ "-Dorg.gradle.java.home=${jdk}" ];
  # using reproducible archives breaks the build
  gradleInitScript = writeText "empty-init-script.gradle" "";

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  wrapper = replaceVars ./freenetWrapper {
    inherit
      bash
      coreutils
      jre
      seednodes
      ;

    # replaced in installPhase
    CLASSPATH = null;
  };

  passthru.tests = {
    inherit (nixosTests) freenet;
  };

  meta = {
    description = "Decentralised and censorship-resistant network";
    homepage = "https://freenetproject.org/";
    changelog = "https://github.com/hyphanet/fred/blob/build${version}/NEWS.md";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ nagy ];
    platforms = with lib.platforms; linux;
    mainProgram = "freenet";
  };
}
