{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
  jre,
  liquibase_redshift_extension,
  makeWrapper,
  mysql_jdbc,
  postgresql_jdbc,
  redshift_jdbc,
  mysqlSupport ? true,
  postgresqlSupport ? true,
  redshiftSupport ? true,
}:

let
  extraJars =
    lib.optional mysqlSupport mysql_jdbc
    ++ lib.optional postgresqlSupport postgresql_jdbc
    ++ lib.optionals redshiftSupport [
      redshift_jdbc
      liquibase_redshift_extension
    ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "liquibase";
  version = "5.0.3";

  src = fetchurl {
    url = "https://github.com/liquibase/liquibase/releases/download/v${finalAttrs.version}/liquibase-${finalAttrs.version}.tar.gz";
    hash = "sha256-hlqrORvpy+P+4iRhOS1dKap2ZSWWWYsUcAo/XwXJ4rc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase =
    let
      addJars = dir: ''
        for jar in ${dir}/*.jar; do
          CP="\$CP":"\$jar"
        done
      '';
    in
    ''
      mkdir -p $out
      mv ./{lib,licenses} $out/

      mkdir -p $out/internal/lib
      mv ./internal/lib/*.jar $out/internal/lib/

      mkdir -p $out/share/doc/liquibase-${finalAttrs.version}
      mv LICENSE.txt \
         README.txt \
         ABOUT.txt \
         changelog.txt \
         $out/share/doc/liquibase-${finalAttrs.version}

      mkdir -p $out/bin
      # there’s a lot of escaping, but I’m not sure how to improve that
      cat > $out/bin/liquibase <<EOF
      #!/usr/bin/env bash
      export LIQUIBASE_ANALYTICS_ENABLED="\''${LIQUIBASE_ANALYTICS_ENABLED:-false}"
      # taken from the executable script in the source
      CP=""
      ${addJars "$out/internal/lib"}
      ${addJars "$out/lib"}
      ${addJars "$out"}
      ${lib.concatStringsSep "\n" (map (p: addJars "${p}/share/java") extraJars)}
      ${lib.getBin jre}/bin/java -cp "\$CP" \$JAVA_OPTS \
      liquibase.integration.commandline.LiquibaseCommandLine \''${1+"\$@"}
      EOF
      chmod +x $out/bin/liquibase
    '';

  sourceRoot = ".";

  passthru.updateScript = gitUpdater {
    # The latest versions are in the 4.xx series.  I am not sure where
    # 10.10.10 and 5.0.0 came from, though it appears like they are
    # for the commercial product.
    ignoredVersions = "10.10.10|5.0.0|.*-beta.*";
    rev-prefix = "v";
    url = "https://github.com/liquibase/liquibase";
  };

  meta = {
    description = "Version Control for your database";
    homepage = "https://www.liquibase.org/";
    changelog = "https://raw.githubusercontent.com/liquibase/liquibase/v${finalAttrs.version}/changelog.txt";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ jsoo1 ];
    platforms = with lib.platforms; unix;
    mainProgram = "liquibase";
  };
})
