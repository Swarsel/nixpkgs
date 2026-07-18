{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  gtk3,
  jdk21,
  makeDesktopItem,
  maven,
  openjfx21,
  wrapGAppsHook3,
}:

let
  jdkWithJFX =
    if jdk21.pname == "openjdk" then
      jdk21.override {
        enableJavaFX = true;
        openjfx21 = openjfx21.override { withWebKit = true; };
      }
    else
      throw "bad jdk variant";
in
maven.buildMavenPackage rec {
  pname = "sportstracker";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "ssaring";
    repo = "sportstracker";
    rev = "SportsTracker-${version}";
    hash = "sha256-5TRTZmBwu33CJieYyt4OtlzVjlfY1FLef9WwKl9iUIw=";
  };

  patches = [
    # We use nixpkgs's JavaFX instead of the one originally fetched by Maven,
    # so we don't even need to fetch it. This avoids having platform-dependent hashes.
    ./remove-pom-jfx.patch
    ./fix-maven-plugin-versions.patch
  ];

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = [ gtk3 ];

  installPhase = ''
    runHook preInstall

    install -Dm644 sportstracker/target/sportstracker-*.jar $out/share/sportstracker/sportstracker.jar
    install -Dm644 sportstracker/target/lib/*.jar -t $out/share/sportstracker/lib
    install -Dm644 sportstracker/docs/* -t $out/share/doc/sportstracker
    install -Dm644 st-packager/icons/linux/SportsTracker.png -t $out/share/icons/hicolor/128x128/apps

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${jdkWithJFX}/bin/java $out/bin/SportsTracker \
        --add-flags "-Djava.awt.headless=true" \
        --add-flags "-jar $out/share/sportstracker/sportstracker.jar" \
        "''${gappsWrapperArgs[@]}"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Sports"
        "Utility"
      ];

      comment = meta.description;
      desktopName = "SportsTracker";
      exec = "SportsTracker";
      icon = "SportsTracker";
      name = "sportstracker";
      terminal = false;
    })
  ];

  # don't double-wrap
  dontWrapGApps = true;
  mvnHash = "sha256-dAANjxM9cEEw+y3tOLHykxjdlVQh8I7pd/9k3lbkgzY=";
  mvnJdk = jdkWithJFX;

  mvnParameters = toString [
    "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z" # set fixed build timestamp for deterministic jar
    "-Dtest=!BindingUtilsToggleGroupTest" # uses DISPLAY
  ];

  meta = {
    description = "Desktop application for people who want to record and analyze their sporting activities";
    homepage = "https://www.saring.de/sportstracker";
    changelog = "https://www.saring.de/sportstracker/CHANGES.txt";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = jdkWithJFX.meta.platforms;
    mainProgram = "SportsTracker";
  };
}
