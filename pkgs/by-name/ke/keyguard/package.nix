{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  cups,
  file,
  fontconfig,
  glib,
  gradle_9,
  gtk3,
  jdk21,
  lcms2,
  libglvnd,
  libxinerama,
  libxrandr,
  makeDesktopItem,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keyguard";
  version = "2.3.4";

  src = fetchFromGitHub {
    owner = "AChep";
    repo = "keyguard-app";
    tag = "r20260201";
    hash = "sha256-7n6/YgRzte2qsgQEfqppdpp5t8+xBjfOKjvNotAgJB0=";
  };

  postPatch = ''
    substituteInPlace desktopLibJvm/build.gradle.kts \
      --replace-fail 'resources.srcDir(rootDir.resolve("desktopLibNative/build/bin/universal"))' "" \
      --replace-fail 'resourcesTask.dependsOn(":desktopLibNative:''${Tasks.compileNativeUniversal}")' ""
  '';

  nativeBuildInputs = [
    gradle_9
    jdk21
    copyDesktopItems
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    libxinerama
    libxrandr
    file
    gtk3
    glib
    cups
    lcms2
    alsa-lib
    libglvnd
  ];

  env.JAVA_HOME = jdk21;
  doCheck = false;

  installPhase = ''
    runHook preInstall

    cp --recursive desktopApp/build/compose/binaries/main-release/app/Keyguard $out
    install -D --mode=0644 $out/lib/Keyguard.png $out/share/icons/hicolor/512x512/apps/keyguard.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Keyguard";
      exec = "Keyguard";
      icon = "keyguard";
      name = "keyguard";
    })
  ];

  gradleBuildTask = ":desktopApp:createReleaseDistributable";
  gradleFlags = [ "-Dorg.gradle.java.home=${jdk21}" ];
  gradleInitScript = writeText "empty-init-script.gradle" "";
  gradleUpdateTask = finalAttrs.gradleBuildTask;

  mitmCache = gradle_9.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
    silent = false;
    useBwrap = false;
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Alternative client for the Bitwarden platform, created to provide the best user experience possible";
    homepage = "https://github.com/AChep/keyguard-app";
    license = lib.licenses.unfree;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ ilkecan ];
    platforms = lib.platforms.linux;
    mainProgram = "Keyguard";
  };
})
