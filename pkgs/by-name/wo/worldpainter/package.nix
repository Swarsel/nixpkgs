{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  gnused,
  jre,
  makeDesktopItem,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "worldpainter";
  version = "2.27.0";

  src = fetchurl {
    url = "https://www.worldpainter.net/files/worldpainter_${version}.tar.gz";
    hash = "sha256-UY2KB6IUlv35wEG9PNU5gWvV5L6KsEiUvJEpqWXSBSA=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    gnused
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/{bin,lib,.install4j/user}

    install -Dm644 bin/*        "$out/bin/"
    install -Dm644 lib/*        "$out/lib/"
    install -Dm644 *.vmoptions  "$out/"
    install -Dm755 worldpainter "$out/bin"
    install -Dm755 wpscript     "$out/bin"
    find .install4j/ -maxdepth 1 -type f -exec install -Dm644 {} "$out/.install4j/" \;
    find .install4j/user/ -maxdepth 1 -type f -exec install -Dm644 {} "$out/.install4j/user/" \;

    mkdir -p $out/share/applications
    install -Dm644 .install4j/i4j_extf_8_jed6s0_1y6kkxa.png   "$out/share/icons/hicolor/128x128/apps/worldpainter.png"
    runHook postInstall
  '';

  postInstall = ''
    sed -i 's/app_home=\./app_home=../' $out/bin/worldpainter
    sed -i 's/app_home=\./app_home=../' $out/bin/wpscript
    wrapProgram $out/bin/worldpainter --prefix PATH : "${jre}/bin"
    wrapProgram $out/bin/wpscript --prefix PATH : "${jre}/bin"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "Paint your own Minecraft worlds";
      desktopName = pname;
      exec = pname;
      icon = pname;
      name = pname;
      startupWMClass = pname;
      terminal = false;
      type = "Application";
    })
  ];

  meta = {
    description = "Interactive map generator for Minecraft";
    longDescription = "WorldPainter is an interactive map generator for Minecraft. It allows you to \"paint\" landscapes using similar tools as a regular paint program. Sculpt and mould the terrain, paint materials, trees, snow and ice, etc. onto it, and much more";
    homepage = "https://www.worldpainter.net/";
    license = with lib.licenses; [ gpl3 ];
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    maintainers = with lib.maintainers; [ eymeric ];
    platforms = lib.platforms.linux;
  };
}
