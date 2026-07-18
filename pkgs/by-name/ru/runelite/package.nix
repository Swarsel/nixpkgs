{
  lib,
  fetchFromGitHub,
  gitUpdater,
  jdk17,
  jre,
  libGL,
  libxxf86vm,
  makeDesktopItem,
  makeWrapper,
  maven,
}:

maven.buildMavenPackage rec {
  pname = "runelite";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "runelite";
    repo = "launcher";
    rev = version;
    hash = "sha256-ckeZ/7rACyZ5j+zzC5hv1NaXTi9q/KvOzMPTDd1crHQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/share/icons
    mkdir -p $out/share/applications

    cp target/RuneLite.jar $out/share
    cp appimage/runelite.png $out/share/icons

    ln -s ${desktop}/share/applications/RuneLite.desktop $out/share/applications/RuneLite.desktop

    makeWrapper ${jre}/bin/java $out/bin/runelite \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libxxf86vm
          libGL
        ]
      }" \
      --add-flags "-jar $out/share/RuneLite.jar"
  '';

  desktop = makeDesktopItem {
    categories = [ "Game" ];
    comment = "Open source Old School RuneScape client";
    desktopName = "RuneLite";
    exec = "runelite";
    genericName = "Oldschool Runescape";
    icon = "runelite";
    name = "RuneLite";
    startupWMClass = "net-runelite-client-RuneLite";
    type = "Application";
  };

  mvnHash = "sha256-OI+m2xJZPnyPXM/HlAsaBJ/z/NCcRSP7+PW5CQOsPiY=";
  mvnJdk = jdk17;
  # tests require internet :(
  mvnParameters = "-Dmaven.test.skip";
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Open source Old School RuneScape client";
    homepage = "https://runelite.net/";
    license = lib.licenses.bsd2;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode
    ];

    maintainers = with lib.maintainers; [
      kmeakin
      moody
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "runelite";
  };
}
