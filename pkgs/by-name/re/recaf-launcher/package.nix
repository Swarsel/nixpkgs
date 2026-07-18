{
  lib,
  stdenv,
  fetchurl,
  buildFHSEnv,
}:
let
  version = "0.8.1";
  jar = fetchurl {
    hash = "sha256-RHsI8z/orwR9b9s+LrrOHpxpr82J6YOpnfik3dnlsvI=";
    url = "https://github.com/Col-E/Recaf-Launcher/releases/download/${version}/recaf-gui-${version}.jar";
  };
in
buildFHSEnv {
  inherit version;
  pname = "recaf-launcher";
  runScript = "java -jar ${jar}";

  targetPkgs =
    p: with p; [
      jar

      openjdk25
      libx11
      at-spi2-atk
      cairo
      gdk-pixbuf
      glib
      gtk3
      pango
      libxtst
      libx11
      xorg_sys_opengl
    ];

  meta = {
    description = "Simple launcher for Recaf 4.X and above - a modern Java bytecode editor";
    homepage = "https://recaf.coley.software";
    changelog = "https://github.com/Col-E/Recaf-Launcher/releases/tag/${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ tudbut ];
    mainProgram = "recaf-launcher";
  };
}
