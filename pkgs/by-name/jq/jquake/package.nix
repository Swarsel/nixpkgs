{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  jre8,
  makeDesktopItem,
  unzip,
  logOutput ? false,
}:

stdenv.mkDerivation rec {
  pname = "jquake";
  version = "1.8.5";

  src = fetchurl {
    url = "https://github.com/fleneindre/fleneindre.github.io/raw/master/downloads/JQuake_${version}_linux.zip";
    sha256 = "sha256-Q9R5Qhk8Qodw2d99nL2aG5WGpIyvKmjzfkRK7xJzoc0=";
  };

  postPatch = ''
    # JQuake emits a lot of debug-like messages on stdout. Either drop the output
    # stream entirely or log them at 'user.debug' level.
    sed -i "/^java/ s/$/ ${
      if logOutput then "| logger -p user.debug" else "> \\/dev\\/null"
    }/" JQuake.sh

    # By default, an 'errors.log' file is created in the current directory.
    # cd into a temporary directory and let it be created there.
    substituteInPlace JQuake.sh \
      --replace "java -jar " "exec ${jre8.outPath}/bin/java -jar $out/lib/" \
      --replace "[JAR FOLDER]" "\$(mktemp -p /tmp -d jquake-errlog-XXX)"
  '';

  nativeBuildInputs = [
    unzip
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    chmod +x JQuake.sh

    mkdir -p $out/{bin,lib}
    mv JQuake.sh $out/bin/JQuake
    mv {JQuake.jar,JQuake_lib} $out/lib
    mv sounds $out/lib

    mkdir -p $out/share/licenses/jquake
    mv LICENSE* $out/share/licenses/jquake

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "Real-time earthquake map of Japan";
      desktopName = "JQuake";
      exec = "JQuake";
      name = "JQuake";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  meta = {
    description = "Real-time earthquake map of Japan";
    homepage = "https://jquake.net";
    changelog = "https://jquake.net/en/changelog.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ nessdoor ];
    platforms = lib.platforms.linux;
    mainProgram = "JQuake";
    downloadPage = "https://jquake.net/en/terms.html?os=linux&arch=any";
  };
}
