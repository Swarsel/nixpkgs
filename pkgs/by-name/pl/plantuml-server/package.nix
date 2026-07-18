{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plantuml-server";
  version = "1.2026.6";

  src = fetchurl {
    url = "https://github.com/plantuml/plantuml-server/releases/download/v${finalAttrs.version}/plantuml-v${finalAttrs.version}.war";
    hash = "sha256-1jcX6GMknJK5dGL74DMwYTDZNVkKI07MpL8qbb0WMi4=";
  };

  postInstall = ''
    mkdir -p "$out/webapps"
    cp "$src" "$out/webapps/plantuml.war"
  '';

  dontUnpack = true;

  passthru.tests = {
    inherit (nixosTests) plantuml-server;
  };

  meta = {
    description = "Web application to generate UML diagrams on-the-fly";
    homepage = "https://plantuml.com/";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      truh
      anthonyroussel
    ];

    platforms = lib.platforms.all;
  };
})
