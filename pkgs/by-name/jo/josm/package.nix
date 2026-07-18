{
  lib,
  stdenv,
  fetchurl,
  fetchsvn,
  jre,
  libxxf86vm,
  makeWrapper,
  unzip,
  extraJavaOpts ? "-Djosm.restart=true -Djava.net.useSystemProxies=true",
}:
let
  pname = "josm";
  version = "19555";
  srcs = {
    jar = fetchurl {
      hash = "sha256-OvpkNeppbaSnZBbRkHqoIVEVhKxhuJYTFDZm1n5reik=";
      url = "https://josm.openstreetmap.de/download/josm-snapshot-${version}.jar";
    };

    macosx = fetchurl {
      hash = "sha256-dVy+gEokVDImS/wOM8h6RqgfAnMHIiSQfb/8BoZICJo=";
      url = "https://josm.openstreetmap.de/download/macosx/josm-macos-${version}-java21.zip";
    };

    pkg = fetchsvn {
      hash = "sha256-sAG9GI0SQpmdDqIXbSH/FN1io/QcsAJFv6/YT483aMA=";
      rev = version;
      url = "https://josm.openstreetmap.de/svn/trunk/native/linux/tested";
    };
  };

  # Needed as of version 19017.
  baseJavaOpts = toString [
    "--add-exports=java.base/sun.security.action=ALL-UNNAMED"
    "--add-exports=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED"
    "--add-exports=java.desktop/com.sun.imageio.spi=ALL-UNNAMED"
  ];
in
stdenv.mkDerivation {
  inherit pname version;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ jre ];

  installPhase =
    if stdenv.hostPlatform.isDarwin then
      ''
        mkdir -p $out/Applications
        ${unzip}/bin/unzip ${srcs.macosx} 'JOSM.app/*' -d $out/Applications
      ''
    else
      ''
        install -Dm644 ${srcs.jar} $out/share/josm/josm.jar
        cp -R ${srcs.pkg}/usr/share $out

        # Add libXxf86vm to path because it is needed by at least Kendzi3D plugin
        makeWrapper ${jre}/bin/java $out/bin/josm \
          --add-flags "${baseJavaOpts} ${extraJavaOpts} -jar $out/share/josm/josm.jar" \
          --prefix LD_LIBRARY_PATH ":" '${libxxf86vm}/lib' \
          --prefix _JAVA_AWT_WM_NONREPARENTING : 1 \
          --prefix _JAVA_OPTIONS " " "-Dawt.useSystemAAFontSettings=gasp"
      '';

  dontUnpack = true;

  passthru = {
    inherit srcs;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Extensible editor for OpenStreetMap";
    homepage = "https://josm.openstreetmap.de/";
    changelog = "https://josm.openstreetmap.de/wiki/Changelog";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

    maintainers = with lib.maintainers; [
      rycee
      sikmir
      starsep
    ];

    platforms = lib.platforms.all;
    mainProgram = "josm";
  };
}
