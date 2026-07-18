{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "hsqldb";
  version = "2.7.4";

  src = fetchurl {
    url = "mirror://sourceforge/project/hsqldb/hsqldb/hsqldb_${underscoreMajMin}/hsqldb-${version}.zip";
    sha256 = "sha256-k4ih0VHD+RV1+kyrx/kiWUqm7P0gEpV66FPoKjpQCNU=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  buildInputs = [ jre ];

  installPhase = ''
     runHook preInstall

     mkdir -p $out/lib $out/bin
     cp -R hsqldb/lib/*.jar $out/lib

     makeWrapper ${jre}/bin/java $out/bin/hsqldb --add-flags "-classpath $out/lib/hsqldb.jar org.hsqldb.server.Server"
     makeWrapper ${jre}/bin/java $out/bin/runServer --add-flags "-classpath $out/lib/hsqldb.jar org.hsqldb.server.Server"
     makeWrapper ${jre}/bin/java $out/bin/runManagerSwing --add-flags "-classpath $out/lib/hsqldb.jar org.hsqldb.util.DatabaseManagerSwing"
     makeWrapper ${jre}/bin/java $out/bin/runWebServer --add-flags "-classpath $out/lib/hsqldb.jar org.hsqldb.server.WebServer"
     makeWrapper ${jre}/bin/java $out/bin/runManager --add-flags "-classpath $out/lib/hsqldb.jar org.hsqldb.util.DatabaseManager"
     makeWrapper ${jre}/bin/java $out/bin/sqltool --add-flags "-jar $out/lib/sqltool.jar"

    runHook postInstall
  '';

  underscoreMajMin = lib.replaceStrings [ "." ] [ "_" ] (lib.versions.majorMinor version);

  meta = {
    description = "Relational, embedable database management system written in Java and a set of related tools";
    homepage = "http://hsqldb.org";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.platforms.unix;
  };
}
