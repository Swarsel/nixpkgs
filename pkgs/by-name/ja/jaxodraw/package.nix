{
  lib,
  copyDesktopItems,
  fetchsvn,
  jdk,
  jre,
  makeDesktopItem,
  makeWrapper,
  maven,
}:

let
  version = "2.1-0-unstable-2025-01-18";
  description = "Java program for drawing Feynman diagrams";
in
maven.buildMavenPackage {
  inherit version;
  pname = "jaxodraw";

  # pom.xml in the 2.1-0 source refers to non-existent ../pom/pom.xml and fails to build.
  # src = fetchurl {
  #   url = "mirror://sourceforge/jaxodraw/jaxodraw-${version}-src.tar.gz";
  #   hash = "sha256-EE0amcFKm/zUO4PzPhkPYZYykZw+ARJFu0/hlUOhu5s=";
  # };
  src = fetchsvn {
    url = "https://svn.code.sf.net/p/jaxodraw/code/trunk/jaxodraw";
    rev = "3346";
    hash = "sha256-jZ2Jvrysb5TeoAw5gubhtn39gMxdAGh/vTsaSIEZ7zs=";
  };

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 target/jaxodraw-*-with-deps.jar $out/lib/jaxodraw/jaxodraw.jar
    makeWrapper ${lib.getExe jre} $out/bin/jaxodraw \
      --add-flags "-jar $out/lib/jaxodraw/jaxodraw.jar"

    install -Dm644 src/site/resources/images/top.png $out/share/icons/hicolor/128x128/apps/jaxodraw.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Science"
        "Education"
        "Physics"
      ];

      comment = description;
      desktopName = "JaxoDraw";
      exec = "jaxodraw";
      icon = "jaxodraw";
      name = "jaxodraw";
    })
  ];

  mvnHash = "sha256-QfMyiz0zWFi3kUwH8pcgu7FiXleP/KO111avs1WWWG0=";
  mvnJdk = jdk;
  mvnParameters = "-PskipTests"; # Tests fail

  meta = {
    inherit description;
    homepage = "https://jaxodraw.sourceforge.io";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ulysseszhan ];
    platforms = lib.platforms.unix;
    mainProgram = "jaxodraw";
  };
}
