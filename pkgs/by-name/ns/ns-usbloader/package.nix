{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  gvfs,
  jre,
  makeDesktopItem,
  makeWrapper,
  maven,
  udevCheckHook,
  wrapGAppsHook3,
}:
let
  pkgDescription = "All-in-one tool for managing Nintendo Switch homebrew";

  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  jreWithJavaFX = jre.override { enableJavaFX = true; };
in
maven.buildMavenPackage rec {
  pname = "ns-usbloader";
  version = "7.2";

  src = fetchFromGitHub {
    owner = "developersu";
    repo = "ns-usbloader";
    rev = "v${version}";
    sha256 = "sha256-nZfAZ+IjoYXEWwH9oOhOQ5TOYUNiAGAqhHRhskyx/Vo=";
  };

  patches = [
    ./no-launch4j.patch
    ./make-deterministic.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    wrapGAppsHook3
    gvfs
    udevCheckHook
  ];

  doCheck = false;

  ### Issues:
  # * Set us to only use software rendering with `-Dprism.order=sw`, had a hard time
  #   getting `prism_es2` happy with NixOS's GL/GLES.
  # * Currently, there's also a lot of `Failed to build parent project for org.openjfx:javafx-*`
  #   at build, but jar runs fine when using `jreWithJavaFX`.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/java
    install -Dm644 target/ns-usbloader-${version}.jar $out/share/java/ns-usbloader.jar

    mkdir -p $out/lib/udev/rules.d
    install -Dm644 ${./99-ns-usbloader.rules} $out/lib/udev/rules.d/99-ns-usbloader.rules

    mkdir -p $out/share/icons/hicolor
    install -Dm644 target/classes/res/app_icon32x32.png $out/share/icons/hicolor/32x32/apps/ns-usbloader.png
    install -Dm644 target/classes/res/app_icon48x48.png $out/share/icons/hicolor/48x48/apps/ns-usbloader.png
    install -Dm644 target/classes/res/app_icon64x64.png $out/share/icons/hicolor/64x64/apps/ns-usbloader.png
    install -Dm644 target/classes/res/app_icon128x128.png $out/share/icons/hicolor/128x128/apps/ns-usbloader.png

    runHook postInstall
  '';

  doInstallCheck = true;

  preFixup = ''
    mkdir -p $out/bin
    makeWrapper ${jreWithJavaFX}/bin/java $out/bin/ns-usbloader \
      --append-flags "-Dprism.order=sw -jar $out/share/java/ns-usbloader.jar" \
      "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = pkgDescription;
      desktopName = "NS-USBLoader";
      exec = "ns-usbloader";
      icon = "ns-usbloader";

      keywords = [
        "nintendo"
        "switch"
      ];

      name = "ns-usbloader";
      terminal = false;
      type = "Application";
    })
  ];

  # Don't wrap binaries twice.
  dontWrapGApps = true;

  # JavaFX pulls in architecture dependent jar dependencies. :(
  # May be possible to unify these, but could lead to huge closure sizes.
  mvnHash = selectSystem {
    aarch64-linux = "sha256-xC+feb41EPi30gBrVR8usanVULI2Pt0knztzNagPQiw=";
    x86_64-linux = "sha256-vXZAlZOh9pXNF1RL78oQRal5pkXFRKDz/7SP9LibgiA=";
  };

  meta = {
    description = pkgDescription;
    homepage = "https://github.com/developersu/ns-usbloader";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ soupglasses ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "ns-usbloader";
  };
}
