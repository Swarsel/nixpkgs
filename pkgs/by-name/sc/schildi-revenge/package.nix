{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  git,
  gradle,
  jdk21,
  libGL,
  nix-update-script,
  rustPlatform,
  rustc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "schildi-revenge";
  version = "26.07.13";

  src = fetchFromGitHub {
    owner = "SchildiChat";
    repo = "schildi-revenge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1Akm57GxGtEymDbfq879uglxEoENp/g+aFUNM1O0qRo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    jdk21
    gradle
    git
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  installPhase = ''
    runHook preInstall

    BUILD_DIR="composeApp/build/compose/binaries/main-release/app/schildichat-revenge"

    mkdir -p $out/share/{applications,icons/scalable}
    cp -r $BUILD_DIR/bin $out/bin
    cp -r $BUILD_DIR/lib $out/lib

    cp -r graphics/ic_launcher_foreground.svg $out/share/icons/scalable/ic_launcher.svg
    cp -r launcher/schildichat-revenge.desktop $out/share/applications

    runHook postInstall
  '';

  postFixup = ''
    patchelf $out/lib/app/libskiko-linux-x64.so \
    --add-rpath ${lib.makeLibraryPath [ libGL ]}
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src cargoRoot;
    hash = "sha256-TIpT2g00f99qTGPA+bBaEz4kj5BC1scEywv6oDCFlkQ=";
  };

  cargoRoot = "matrix-rust-sdk";
  gradleBuildTask = "createReleaseDistributable";

  gradleUpdateScript = ''
    runHook preBuild

    gradle composeApp:dependencies composeApp:checkRuntime --write-verification-metadata sha256
    ##### Fallback
    ## If the update script starts missing dependencies after an update this should still work.
    ## Unfortunately it also unnecessarily builds the entire rust crate
    #gradle createReleaseDistributable --write-verification-metadata sha256
  '';

  mitmCache = gradle.fetchDeps {
    data = ./deps.json;
    pkg = finalAttrs.finalPackage;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Matrix client for desktop written in Kotlin and using the Matrix Rust SDK";
    homepage = "https://schildi.chat/revenge";
    license = lib.licenses.gpl3Only;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # mitm cache
    ];

    maintainers = with lib.maintainers; [
      _71rd
      xeni
    ];

    platforms = lib.platforms.linux;
    mainProgram = "schildichat-revenge";
  };
})
