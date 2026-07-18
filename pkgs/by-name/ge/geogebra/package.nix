{
  lib,
  stdenv,
  fetchurl,
  jre,
  libGL,
  libxxf86vm,
  makeDesktopItem,
  makeWrapper,
  unzip,
  language ? "en_US",
}:
let
  pname = "geogebra";
  version = "5-0-785-0";

  srcIcon = fetchurl {
    hash = "sha256-Vd7Wteya04JJT4WNirXe8O1sfVKUgc0hKGOy7d47Xgc=";
    url = "https://web.archive.org/web/20200227000442if_/https://static.geogebra.org/images/geogebra-logo.svg";
  };

  desktopItem = makeDesktopItem {
    categories = [
      "Education"
      "Science"
      "Math"
    ];

    comment = meta.description;
    desktopName = "Geogebra";
    exec = "geogebra";
    genericName = "Geogebra";
    icon = "geogebra";

    mimeTypes = [
      "application/vnd.geogebra.file"
      "application/vnd.geogebra.tool"
    ];

    name = "geogebra";
  };

  meta = {
    description = "Dynamic mathematics software with graphics, algebra and spreadsheets";

    longDescription = ''
      Dynamic mathematics software for all levels of education that brings
      together geometry, algebra, spreadsheets, graphing, statistics and
      calculus in one easy-to-use package.
    '';

    homepage = "https://www.geogebra.org/";

    license = with lib.licenses; [
      gpl3
      cc-by-nc-sa-30
      geogebra
    ];

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
      binaryNativeCode # some jars include native binaries
    ];

    maintainers = with lib.maintainers; [
      sikmir
      soupglasses
    ];

    platforms = with lib.platforms; linux ++ darwin;
    hydraPlatforms = [ ];
  };

  linuxPkg = stdenv.mkDerivation {
    inherit
      pname
      version
      meta
      srcIcon
      desktopItem
      ;

    src = fetchurl {
      hash = "sha256-cL4ERKZpE9Y6IdOjvYiX3nIIW3E2qoqkpMyTszvFseM=";

      urls = [
        "https://download.geogebra.org/installers/5.0/GeoGebra-Linux-Portable-${version}.tar.bz2"
        "https://web.archive.org/web/20230627211902/https://download.geogebra.org/installers/5.0/GeoGebra-Linux-Portable-${version}.tar.bz2"
      ];
    };

    nativeBuildInputs = [ makeWrapper ];

    installPhase = ''
      install -D geogebra/* -t "$out/libexec/geogebra/"

      # The bundled jogl (required for 3D graphics) links to libxxf86vm, and loads libGL at runtime
      # OpenGL versions newer than 3.0 cause "javax.media.opengl.GLException: Not a GL2 implementation"
      makeWrapper "$out/libexec/geogebra/geogebra" "$out/bin/geogebra" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            libGL
            libxxf86vm
          ]
        }" \
        --set MESA_GL_VERSION_OVERRIDE 3.0 \
        --set JAVACMD "${jre}/bin/java" \
        --set GG_PATH "$out/libexec/geogebra" \
        --add-flags "--language=${language}"

      install -Dm644 "${desktopItem}/share/applications/"* \
        -t $out/share/applications/

      install -Dm644 "${srcIcon}" \
        "$out/share/icons/hicolor/scalable/apps/geogebra.svg"
    '';

    preferLocalBuild = true;
  };

  darwinPkg = stdenv.mkDerivation {
    inherit pname version meta;

    src = fetchurl {
      hash = "sha256-KHjNH8c3/aMJ5CcwCwW9z0QRxJwqYU5I610zpMMruBQ=";

      urls = [
        "https://download.geogebra.org/installers/5.0/GeoGebra-MacOS-Installer-withJava-${version}-x64.zip"
        "https://web.archive.org/web/20230627211427/https://download.geogebra.org/installers/5.0/GeoGebra-MacOS-Installer-withJava-${version}-x64.zip"
      ];
    };

    nativeBuildInputs = [ unzip ];

    installPhase = ''
      install -dm755 $out/Applications
      unzip $src -d $out/Applications
    '';

    dontUnpack = true;
    preferLocalBuild = true;
  };
in
if stdenv.hostPlatform.isDarwin then darwinPkg else linuxPkg
