{
  lib,
  fetchurl,
  gitUpdater,
  jre,
  nixosTests,
  stdenvNoCC,
  testers,
}:

let
  common =
    { hash, version }:
    stdenvNoCC.mkDerivation (finalAttrs: {
      inherit version;
      pname = "apache-tomcat";

      src = fetchurl {
        inherit hash;
        url = "mirror://apache/tomcat/tomcat-${lib.versions.major version}/v${version}/bin/apache-tomcat-${version}.tar.gz";
      };

      outputs = [
        "out"
        "webapps"
      ];

      installPhase = ''
        mkdir $out
        mv * $out
        mkdir -p $webapps/webapps
        mv $out/webapps $webapps/
      '';

      passthru = {
        tests = {
          inherit (nixosTests) tomcat;

          version = testers.testVersion {
            command = "JAVA_HOME=${jre} ${finalAttrs.finalPackage}/bin/version.sh";
            package = finalAttrs.finalPackage;
          };
        };

        updateScript = gitUpdater {
          allowedVersions = "^${lib.versions.major version}\\.";
          ignoredVersions = "-M.*";
          url = "https://github.com/apache/tomcat.git";
        };
      };

      meta = {
        description = "Implementation of the Java Servlet and JavaServer Pages technologies";
        homepage = "https://tomcat.apache.org/";
        license = lib.licenses.asl20;
        sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
        maintainers = with lib.maintainers; [ anthonyroussel ];
        platforms = jre.meta.platforms;
      };
    });

in
{
  tomcat10 = common {
    version = "10.1.55";
    hash = "sha256-l4oNCJA0XuxSo4yWcKjhEtTMjPjLEO9B0F1rcXiFdJU=";
  };

  tomcat11 = common {
    version = "11.0.22";
    hash = "sha256-c9I5Iy8U394ieOjZMfdn7UVK7ZsBjk1wodQEwlebWZg=";
  };

  tomcat9 = common {
    version = "9.0.118";
    hash = "sha256-L9Me+dqZKbh4mX9zHPJVNv6sV0FhwC2TmXJ0ccfEBrI=";
  };
}
