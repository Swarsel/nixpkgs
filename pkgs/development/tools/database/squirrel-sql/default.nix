# To enable specific database drivers, override this derivation and pass the
# driver packages in the drivers argument (e.g. mysql_jdbc, postgresql_jdbc).
{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeDesktopItem,
  makeWrapper,
  unzip,
  drivers ? [ ],
}:
stdenv.mkDerivation rec {
  pname = "squirrel-sql";
  version = "5.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/squirrel-sql/1-stable/${version}-plainzip/squirrelsql-${version}-standard.zip";
    sha256 = "sha256-aYwA2TRXI74s1BXfhlatBqPzC1xCfEqTe/yK8DCMo4E=";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildInputs = [ jre ];

  buildPhase = ''
    runHook preBuild
    cd squirrelsql-${version}-standard
    chmod +x squirrel-sql.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/squirrel-sql
    cp -r . $out/share/squirrel-sql

    mkdir -p $out/bin
    cp=""
    for pkg in ${builtins.concatStringsSep " " drivers}; do
      if test -n "$cp"; then
        cp="$cp:"
      fi
      cp="$cp"$(echo $pkg/share/java/*.jar | tr ' ' :)
    done
    makeWrapper $out/share/squirrel-sql/squirrel-sql.sh $out/bin/squirrel-sql \
      --set CLASSPATH "$cp" \
      --set JAVA_HOME "${jre}"
    # Make sure above `CLASSPATH` gets picked up
    substituteInPlace $out/share/squirrel-sql/squirrel-sql.sh --replace "-cp \"\$CP\"" "-cp \"\$CLASSPATH:\$CP\""

    mkdir -p $out/share/icons/hicolor/32x32/apps
    ln -s $out/share/squirrel-sql/icons/acorn.png \
      $out/share/icons/hicolor/32x32/apps/squirrel-sql.png
    ln -s ${desktopItem}/share/applications $out/share

    runHook postInstall
  '';

  desktopItem = makeDesktopItem {
    categories = [ "Development" ];
    comment = meta.description;
    desktopName = "SQuirreL SQL";
    exec = "squirrel-sql";
    genericName = "SQL Client";
    icon = "squirrel-sql";
    name = "squirrel-sql";
  };

  unpackPhase = ''
    runHook preUnpack
    unzip ${src}
    runHook postUnpack
  '';

  meta = {
    description = "Universal SQL Client";
    homepage = "http://squirrel-sql.sourceforge.net/";
    license = lib.licenses.lgpl21Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.linux;
    mainProgram = "squirrel-sql";
  };
}
