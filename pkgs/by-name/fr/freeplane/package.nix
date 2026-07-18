{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  fetchpatch,
  gradle_9,
  jdk17,
  makeBinaryWrapper,
  makeDesktopItem,
  stdenvNoCC,
  which,
}:

let
  pname = "freeplane";
  version = "1.13.2";

  jdk = jdk17;
  gradle = gradle_9;

  src = fetchFromGitHub {
    owner = "freeplane";
    repo = "freeplane";
    rev = "release-${version}";
    hash = "sha256-NDji6psNXESAY5NWI/Ms63MTgbxZHiIxYAgOSkWHuK0=";
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version src;

  patches = [
    # Gradle 9.5 compatibility. Remove on next version bump.
    (fetchpatch {
      hash = "sha256-gVCKXme+pB7PV0yBoDMPg6ltCaTGYh1lspEKgwVkDgc=";
      url = "https://github.com/freeplane/freeplane/commit/34189b58bbdf0027185a212e2d6bd9e289782ef2.patch";
    })
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    jdk
    gradle
    copyDesktopItems
  ];

  preBuild = "mkdir -p freeplane/build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share
    cp -a ./BIN/. $out/share/freeplane

    makeWrapper $out/share/freeplane/freeplane.sh $out/bin/freeplane \
      --set FREEPLANE_BASE_DIR $out/share/freeplane \
      --set JAVA_HOME ${jdk} \
      --prefix PATH : ${
        lib.makeBinPath [
          jdk
          which
        ]
      } \
      --prefix _JAVA_AWT_WM_NONREPARENTING : 1 \
      --prefix _JAVA_OPTIONS " " "-Dawt.useSystemAAFontSettings=gasp"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "2DGraphics"
        "Chart"
        "Graphics"
        "Office"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "freeplane";
      exec = "freeplane";
      genericName = "Mind-mapper";
      icon = "freeplane";

      mimeTypes = [
        "application/x-freemind"
        "application/x-freeplane"
        "text/x-troff-mm"
      ];

      name = "freeplane";
    })
  ];

  # share/freeplane/core/org.freeplane.core/META-INF doesn't
  # always get generated with parallel building enabled
  enableParallelBuilding = false;
  gradleBuildTask = "build";

  gradleFlags = [
    "-Dorg.gradle.java.home=${jdk}"
    "-x"
    "test"
  ];

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  meta = {
    description = "Mind-mapping software";
    homepage = "https://freeplane.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "freeplane";
  };
})
