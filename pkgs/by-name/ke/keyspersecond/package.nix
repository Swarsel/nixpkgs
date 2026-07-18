{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  gradle_8,
  jre,
  libGL,
  libx11,
  libxcb,
  libxinerama,
  libxkbcommon,
  libxt,
  libxtst,
  makeDesktopItem,
  makeWrapper,
}:

let
  gradle = gradle_8;

  libPath = lib.makeLibraryPath [
    # used by the Java2D OpenGL backend
    libGL
    # jnativehook dependencies
    libx11
    libxtst
    libxkbcommon
    libxcb
    libxt
    libxinerama
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "keyspersecond";
  version = "8.9";

  src = fetchFromGitHub {
    owner = "RoanH";
    repo = "KeysPerSecond";
    rev = "v${finalAttrs.version}";
    hash = "sha256-DGpXbCInq+RS56Ae5Y6xzyWqwXAm26c0vOYrFqDvl+8=";
  };

  patches = [
    # deprecated shadowJar.archiveName, application.mainClassName
    # patches already in `master` branch, but no new release yet
    # and would be spread along multiple cherry-picks
    ./gradleShadowJar.patch
  ];

  nativeBuildInputs = [
    gradle
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 resources/kps.png $out/share/icons/hicolor/64x64/apps/keyspersecond.png
    install -Dm644 build/libs/KeysPerSecond-v*.jar $out/share/keyspersecond/KeysPerSecond.jar

    # Note: we need to enable the Java2D OpenGL backend for proper transparency support
    makeWrapper ${jre}/bin/java $out/bin/KeysPerSecond \
        --prefix LD_LIBRARY_PATH : ${libPath} \
        --add-flags "-Dsun.java2d.opengl=True" \
        --add-flags "-jar $out/share/keyspersecond/KeysPerSecond.jar"

    runHook postInstall
  '';

  # this is required for using mitm-cache on Darwin
  __darwinAllowLocalNetworking = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = finalAttrs.meta.description;
      desktopName = "KeysPerSecond";
      exec = "KeysPerSecond";
      icon = "keyspersecond";
      name = "keyspersecond";
    })
  ];

  gradleFlags = "-PrefName=v${finalAttrs.version}";

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
  };

  sourceRoot = "${finalAttrs.src.name}/KeysPerSecond";

  meta = {
    description = "Keys-per-second meter and counter for rhythm games";
    homepage = "https://github.com/RoanH/KeysPerSecond";
    changelog = "https://github.com/RoanH/KeysPerSecond/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
      binaryNativeCode # jnativehook shared library
    ];

    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = jre.meta.platforms;
    mainProgram = "KeysPerSecond";
  };
})
