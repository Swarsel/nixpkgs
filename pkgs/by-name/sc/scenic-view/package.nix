{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle_7,
  makeDesktopItem,
  makeWrapper,
  openjdk,
  openjfx,
}:
let
  jdk = openjdk.override (
    lib.optionalAttrs stdenv.hostPlatform.isLinux {
      enableJavaFX = true;
      openjfx_jdk = openjfx.override { withWebKit = true; };
    }
  );

  pname = "scenic-view";
  version = "11.0.2";

  src = fetchFromGitHub {
    owner = "JonathanGiles";
    repo = "scenic-view";
    rev = version;
    sha256 = "1idfh9hxqs4fchr6gvhblhvjqk4mpl4rnpi84vn1l3yb700z7dwy";
  };

  gradle = gradle_7;

  desktopItem = makeDesktopItem {
    categories = [ "Development" ];
    comment = "JavaFx application to visualize and modify the scenegraph of running JavaFx applications.";
    desktopName = "scenic-view";
    exec = "scenic-view";

    mimeTypes = [
      "application/java"
      "application/java-vm"
      "application/java-archive"
    ];

    name = "scenic-view";
  };

in
stdenv.mkDerivation rec {
  inherit pname version src;

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/scenic-view
    cp build/libs/scenicview.jar $out/share/scenic-view/scenic-view.jar
    makeWrapper ${jdk}/bin/java $out/bin/scenic-view --add-flags "-jar $out/share/scenic-view/scenic-view.jar"

    runHook postInstall
  '';

  __darwinAllowLocalNetworking = true;
  desktopItems = [ desktopItem ];

  mitmCache = gradle.fetchDeps {
    inherit pname;
    data = ./deps.json;
  };

  meta = {
    description = "JavaFx application to visualize and modify the scenegraph of running JavaFx applications";

    longDescription = ''
      A JavaFX application designed to make it simple to understand the current state of your application scenegraph
      and to also easily manipulate properties of the scenegraph without having to keep editing your code.
      This lets you find bugs and get things pixel perfect without having to do the compile-check-compile dance.
    '';

    homepage = "https://github.com/JonathanGiles/scenic-view/";
    license = lib.licenses.gpl3Plus;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode # deps
    ];

    maintainers = with lib.maintainers; [ wirew0rm ];
    platforms = lib.platforms.all;
    mainProgram = "scenic-view";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
