{
  lib,
  stdenv,
  fetchurl,
  cairo,
  copyDesktopItems,
  fetchzip,
  gdk-pixbuf,
  glib,
  gtk3,
  jdk11,
  libxtst,
  makeBinaryWrapper,
  makeDesktopItem,
  openjfx17,
  pango,
}:

let
  openjfx_jdk = openjfx17.override { withWebKit = true; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "conduktor";
  version = "2.24.9";

  src = fetchzip {
    url = "https://github.com/conduktor/builds/releases/download/v${finalAttrs.version}/Conduktor-linux-${finalAttrs.version}.zip";
    hash = "sha256-c9QjlKPZpeJi5YTq4gm+sg7my4EP0LI95AfGguF4ork=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall

    cp -r . $out
    wrapProgram $out/bin/conduktor \
      --set JAVA_HOME ${jdk11.home} \
      --set LD_LIBRARY_PATH ${
        lib.makeLibraryPath [
          openjfx_jdk
          gtk3
          gtk3
          glib
          pango
          cairo
          gdk-pixbuf
          libxtst
        ]
      } \
       --add-flags "--module-path ${openjfx_jdk}/lib --add-modules=javafx.controls,javafx.fxml"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "A beautiful and fully-featured desktop client for Apache Kafka";
      desktopName = "Conduktor";
      exec = "conduktor";
      genericName = finalAttrs.meta.description;

      icon = fetchurl {
        hash = "sha256-mk4c9ecookRb7gR56cedIWfPfQy2uGF+ZbX6NI90KI0=";
        url = "https://github.com/conduktor/builds/raw/v${finalAttrs.version}/.github/resources/Conduktor.png";
      };

      name = "conduktor";
      type = "Application";
    })
  ];

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Apache Kafka Desktop Client";

    longDescription = ''
      Conduktor is a GUI over the Kafka ecosystem, to make the development
      and management of Apache Kafka clusters as easy as possible.
    '';

    homepage = "https://www.conduktor.io/";
    changelog = "https://www.conduktor.io/changelog/#${finalAttrs.version}";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ trobert ];
    platforms = lib.platforms.linux;
  };
})
