{
  lib,
  stdenv,
  mysql_jdbc,
}:

stdenv.mkDerivation {
  inherit (mysql_jdbc) version;
  pname = "jboss-mysql-jdbc";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/server/default/lib
    ln -s $mysql_jdbc/share/java/mysql-connector-java.jar $out/server/default/lib/mysql-connector-java.jar

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    inherit (mysql_jdbc.meta)
      description
      license
      platforms
      homepage
      ;

    maintainers = [ ];
  };
}
