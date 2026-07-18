{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  desktopToDarwinBundle,
  gradle_8,
  jdk,
  librsvg,
  makeBinaryWrapper,
  makeDesktopItem,
  quark-engine,
}:
let
  # "Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0."
  gradle = gradle_8;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jadx";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "skylot";
    repo = "jadx";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WONsXDNhlDuqKsS2Olz3ndZIbi6mdi9JBKaHPpcdTQQ=";
  };

  patches = [
    # Remove launch4j (uncacheable Windows binaries) and OpenRewrite (build failures)
    ./nix-build.patch
  ];

  nativeBuildInputs = [
    gradle
    jdk
    librsvg
    makeBinaryWrapper
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  preBuild = "export JADX_VERSION=${finalAttrs.version}";

  installPhase = ''
    runHook preInstall

    mkdir $out $out/bin
    cp -R build/jadx/lib $out
    for prog in jadx jadx-gui; do
      cp build/jadx/bin/$prog $out/bin
      wrapProgram $out/bin/$prog \
        --set JAVA_HOME ${jdk.home} \
        --prefix PATH : "${lib.makeBinPath [ quark-engine ]}"
    done

    for size in 16 32 48; do
      install -Dm444 \
        jadx-gui/src/main/resources/logos/jadx-logo-"$size"px.png \
        $out/share/icons/hicolor/"$size"x"$size"/apps/jadx.png
    done
    for size in 64 128 256; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      rsvg-convert --width "$size" jadx-gui/src/main/resources/logos/jadx-logo.svg > $out/share/icons/hicolor/"$size"x"$size"/apps/jadx.png
    done

    runHook postInstall
  '';

  # Otherwise, Gradle fails with `java.net.SocketException: Operation not permitted`
  __darwinAllowLocalNetworking = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Utility"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "JADX";
      exec = "jadx-gui";
      icon = "jadx";
      name = "jadx";
    })
  ];

  gradleBuildTask = "pack";

  mitmCache = gradle.fetchDeps {
    pname = "jadx";
    data = ./deps.json;
  };

  meta = {
    description = "Dex to Java decompiler";

    longDescription = ''
      Command line and GUI tools for produce Java source code from Android Dex
      and Apk files.
    '';

    homepage = "https://github.com/skylot/jadx";
    changelog = "https://github.com/skylot/jadx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];

    maintainers = with lib.maintainers; [
      emilytrau
      Misaka13514
    ];

    platforms = lib.platforms.unix;
    mainProgram = "jadx-gui";
  };
})
