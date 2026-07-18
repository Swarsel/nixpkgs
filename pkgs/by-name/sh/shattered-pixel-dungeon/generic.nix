# Generic builder for shattered pixel forks/mods
{
  lib,
  stdenv,
  copyDesktopItems,
  desktopName,
  gradle_8,
  jre,
  libGL,
  libpulseaudio,
  makeDesktopItem,
  makeWrapper,
  meta,
  perl,
  pname,
  src,
  version,
  depsPath ? null,
  patches ? [ ./disable-beryx.patch ],
  ...
}@attrs:

let
  cleanAttrs = removeAttrs attrs [
    "lib"
    "stdenv"
    "makeWrapper"
    "gradle"
    "perl"
    "jre"
    "libpulseaudio"
    "makeDesktopItem"
    "copyDesktopItems"
  ];

  postPatch = ''
    # disable gradle plugins with native code and their targets
    perl -i.bak1 -pe "s#(^\s*id '.+' version '.+'$)#// \1#" build.gradle
    perl -i.bak2 -pe "s#(.*)#// \1# if /^(buildscript|task portable|task nsis|task proguard|task tgz|task\(afterEclipseImport\)|launch4j|macAppBundle|buildRpm|buildDeb|shadowJar|robovm|git-version)/ ... /^}/" build.gradle
    # Remove unbuildable Android/iOS stuff
    rm -f android/build.gradle ios/build.gradle
    ${attrs.postPatch or ""}
  '';

  desktopItem = makeDesktopItem {
    inherit desktopName;

    categories = [
      "Game"
      "AdventureGame"
    ];

    comment = meta.description;
    exec = pname;
    icon = pname;

    keywords = [
      "roguelike"
      "dungeon"
      "crawler"
    ];

    name = pname;
    terminal = false;
  };

  depsPath' = if depsPath != null then depsPath else ./. + "/${pname}/deps.json";

  # "Deprecated Gradle features were used in this build, making it incompatible with Gradle 9.0."
  gradle = gradle_8;

in
stdenv.mkDerivation (
  cleanAttrs
  // {
    inherit
      pname
      version
      src
      patches
      postPatch
      ;

    nativeBuildInputs = [
      gradle
      perl
      makeWrapper
      copyDesktopItems
    ]
    ++ attrs.nativeBuildInputs or [ ];

    installPhase = ''
      runHook preInstall

      install -Dm644 desktop/build/libs/desktop-*.jar $out/share/${pname}.jar
      mkdir $out/bin
      makeWrapper ${jre}/bin/java $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            libGL
            libpulseaudio
          ]
        } \
        --add-flags "-jar $out/share/${pname}.jar"

      for s in 16 32 48 64 128 256; do
        # Some forks only have some icons and/or name them slightly differently
        if [ -f desktop/src/main/assets/icons/icon_$s.png ]; then
          install -Dm644 desktop/src/main/assets/icons/icon_$s.png \
            $out/share/icons/hicolor/''${s}x$s/apps/${pname}.png
        fi
        if [ -f desktop/src/main/assets/icons/icon_''${s}x$s.png ]; then
          install -Dm644 desktop/src/main/assets/icons/icon_''${s}x$s.png \
            $out/share/icons/hicolor/''${s}x$s/apps/${pname}.png
        fi
      done

      runHook postInstall
    '';

    __darwinAllowLocalNetworking = true;
    desktopItems = [ desktopItem ];
    gradleBuildTask = "desktop:release";

    mitmCache = gradle.fetchDeps {
      inherit pname;
      data = depsPath';
    };

    meta =

      {
        license = lib.licenses.gpl3Plus;

        sourceProvenance = with lib.sourceTypes; [
          fromSource
          binaryBytecode # deps
        ];

        maintainers = with lib.maintainers; [ fgaz ];
        platforms = lib.platforms.all;
        mainProgram = pname;
      }
      // meta;
  }
)
