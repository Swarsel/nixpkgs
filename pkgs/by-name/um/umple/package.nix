{
  lib,
  fetchurl,
  fetchFromGitHub,
  gradle_8, # incompatible with gradle 9+
  installShellFiles,
  jre_headless,
  makeBinaryWrapper,
  opentxl,
  runCommand,
  stdenvNoCC,
}:
let
  versions = lib.importJSON ./versions.json;
  inherit (versions.umple) version longVersion;

  # Required for bootstrapping
  umpleJar = fetchurl versions.umpleJar;

  # Not managed through Gradle
  joptSimple = fetchFromGitHub {
    hash = "sha256-sOQaEq2qzvEwJzwZIcMQus3tetzA6O2VPl8XUJAtupM=";
    owner = "jopt-simple";
    repo = "jopt-simple";
    tag = "jopt-simple-4.4";
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit version;
  pname = "umple";

  src = fetchFromGitHub {
    owner = "umple";
    repo = "umple";
    tag = "v${version}";
    hash = "sha256-BPy1L3bzvKoywM0srv36SXVe8psaY/m0bljy30z5dr8=";
  };

  patches = [
    # The upstream project uses some deprecated Gradle 7 features and old dependencies
    ./gradle-8-compat.patch
    # Replaces the logic to determine the current version (requires Git at runtime)
    ./replace-version.patch
    # Fixes broken working directory + updates Jar paths for manpage generation task
    ./fix-manpage.patch
  ];

  postPatch = ''
    # Set variables from patches + use Nix store paths
    substituteInPlace build.gradle \
      --replace-fail @UMPLE_VERSION@ "${longVersion}" \
      --replace-fail @UMPLE_OUT_JAR@ "umple-${longVersion}.jar" \
      --replace-fail '${"$"}{rootProject.projectDir.toString()}/libs/umple-latest.jar' '${umpleJar}' \
      --replace-fail '${"$"}{rootProject.projectDir.toString()}/dist/gradle/libs/vendors/jopt-simple-jopt-simple-4.4/src/main/java/joptsimple' '${joptSimple}/src/main/java/joptsimple'

    # Replace outdated version in manpage
    substituteInPlace build/package-files/template.1 \
      --replace-warn 1.31.1 "${longVersion}"

    # Replace @UMPLE_VERSION@ template in original source code with actual version.
    # This ensures that emitted files include comments indicating the proper version,
    # e.g. "Generated with Umple x.y.z"
    find . -type f \( -name '*.java' -o -name '*.ump' \) -exec sed -i "s/@UMPLE_VERSION@/${longVersion}/g" {} +
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gradle_8
    gradle_8.jdk
    installShellFiles
    makeBinaryWrapper
    opentxl
  ];

  postBuild = ''
    gradle --no-daemon genManpage
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/java}
    cp dist/gradle/libs/umple*.jar $out/share/java
    installManPage build/package-files/umple.1

    pushd $out/share/java
    # Strip version suffix from filenames
    for file in *.jar; do
      mv "$file" "''${file%-${longVersion}.jar}.jar"
    done
    # Create wrappers
    for file in *.jar; do
      makeWrapper ${lib.getExe jre_headless} "$out/bin/''${file%.jar}" \
        --add-flags "-jar $out/share/java/$file"
    done
    popd

    runHook postInstall
  '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  gradleBuildTask = "quickbuild";

  gradleFlags = [
    # Network-dependent tasks
    "--exclude-task=downloadUmpleJar"
    "--exclude-task=downloadJOptSimpleVendorZip"
    "--exclude-task=downloadAndUnzipJOptSimpleVendor"
    "--exclude-task=prepareJOptSimpleVendor"
    # Tasks that try to modify readonly files
    "--exclude-task=cleanUpUmple"
  ];

  mitmCache = gradle_8.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  passthru = {
    bootstrap = umpleJar;

    tests."2dshapes" =
      runCommand "umple-test"
        {
          src = ./2DShapes.ump;

          nativeBuildInputs = [
            finalAttrs.finalPackage
            gradle_8.jdk
          ];
        }
        ''
          set -euo pipefail
          cp $src .
          umple $(basename $src)
          javac -d bin Shapes/core/*.java
          java -cp bin Shapes.core.Shape2D
          touch $out
        '';

    updateScript = ./update.sh;
  };

  meta = {
    description = "Model-oriented programming language and modelling tool for integrating UML constructs into high-level languages";
    homepage = "https://github.com/umple/umple";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ MysteryBlokHed ];
    mainProgram = "umple";
    downloadPage = "https://github.com/umple/umple/releases";
  };
})
