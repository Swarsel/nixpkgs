{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeDesktopItem,
  runtimeShell,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swingsane";
  version = "0.2";

  src = fetchurl {
    url = "mirror://sourceforge/swingsane/swingsane-${finalAttrs.version}-bin.zip";
    sha256 = "15pgqgyw46yd2i367ax9940pfyvinyw2m8apmwhrn0ix5nywa7ni";
  };

  nativeBuildInputs = [ unzip ];

  installPhase =
    let

      execWrapper = ''
        #!${runtimeShell}
        exec ${jre}/bin/java -jar $out/share/java/swingsane/swingsane-${finalAttrs.version}.jar "$@"
      '';

      desktopItem = makeDesktopItem {
        categories = [ "Office" ];
        comment = finalAttrs.meta.description;
        desktopName = "SwingSane";
        exec = "swingsane";
        genericName = "Scan from local or remote SANE servers";
        icon = "swingsane";
        name = "swingsane";
      };

    in
    ''
      install -v -m 755    -d $out/share/java/swingsane/
      install -v -m 644 *.jar $out/share/java/swingsane/

      echo "${execWrapper}" > swingsane
      install -v -D -m 755 swingsane $out/bin/swingsane

      unzip -j swingsane-${finalAttrs.version}.jar "com/swingsane/images/*.png"
      install -v -D -m 644 swingsane_512x512.png $out/share/icons/hicolor/512x512/apps/swingsane.png

      cp -v -r ${desktopItem}/share/applications $out/share
    '';

  dontConfigure = true;

  meta = {
    description = "Java GUI for SANE scanner servers (saned)";

    longDescription = ''
      SwingSane is a powerful, cross platform, open source Java front-end for
      using both local and remote Scanner Access Now Easy (SANE) servers.
      The most powerful feature is its ability to query back-ends for scanner
      specific options which can be set by the user as a scanner profile.
      It also has support for authentication, mutlicast DNS discovery,
      simultaneous scan jobs, image transformation jobs (deskew, binarize,
      crop, etc), PDF and PNG output.
    '';

    homepage = "http://swingsane.com/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.all;
    mainProgram = "swingsane";
  };
})
