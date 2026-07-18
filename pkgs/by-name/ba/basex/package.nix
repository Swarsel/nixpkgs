{
  lib,
  stdenv,
  fetchurl,
  copyDesktopItems,
  coreutils,
  jre,
  makeDesktopItem,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "basex";
  version = "12.4";

  src = fetchurl {
    url = "http://files.basex.org/releases/${finalAttrs.version}/BaseX${
      builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }.zip";

    hash = "sha256-qIaAy05V5JUZ+YuuesFecCvdpCYoZm0/dWFnInpHvKE=";
  };

  nativeBuildInputs = [
    unzip
    copyDesktopItems
  ];

  buildInputs = [ jre ];

  installPhase = ''
    runHook preInstall

    # Remove Windows batch files (unclutter $out/bin)
    rm ./bin/*.bat

    mkdir -p "$out/share/basex"

    cp -R bin etc lib webapp src BaseX.jar "$out"
    cp -R readme.txt webapp "$out/share/basex"

    # Use substitutions instead of wrapper scripts
    for file in "$out"/bin/*; do
        sed -i -e "s|/usr/bin/env bash|${stdenv.shell}|" \
               -e "s|java|${jre}/bin/java|" \
               -e "s|readlink|${coreutils}/bin/readlink|" \
               -e "s|dirname|${coreutils}/bin/dirname|" \
               -e "s|basename|${coreutils}/bin/basename|" \
               -e "s|echo|${coreutils}/bin/echo|" \
            "$file"
    done

    runHook postInstall
  '';

  desktopItems = lib.optional (!stdenv.hostPlatform.isDarwin) (makeDesktopItem {
    categories = [
      "Development"
      "Utility"
      "Database"
    ];

    comment = "Visually query and analyse your XML data";
    desktopName = "BaseX XML Database";
    exec = "basexgui %f";
    genericName = "XML database tool";
    icon = "${./basex.svg}"; # icon copied from Ubuntu basex package
    mimeTypes = [ "text/xml" ];
    name = "basex";
  });

  dontBuild = true;

  meta = {
    description = "XML database and XPath/XQuery processor";

    longDescription = ''
      BaseX is a very fast and light-weight, yet powerful XML database and
      XPath/XQuery processor, including support for the latest W3C Full Text
      and Update Recommendations. It supports large XML instances and offers a
      highly interactive front-end (basexgui). Apart from two local standalone
      modes, BaseX offers a client/server architecture.
    '';

    homepage = "https://basex.org/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.unix;
  };
})
