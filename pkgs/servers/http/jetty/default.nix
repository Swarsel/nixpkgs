{
  lib,
  fetchurl,
  gitUpdater,
  stdenvNoCC,
}:

let
  common =
    { hash, version }:
    stdenvNoCC.mkDerivation rec {
      inherit version;
      pname = "jetty";

      src = fetchurl {
        inherit hash;
        url = "mirror://maven/org/eclipse/jetty/jetty-home/${version}/jetty-home-${version}.tar.gz";
      };

      installPhase = ''
        mkdir -p $out
        mv etc lib modules start.jar $out
      '';

      dontBuild = true;

      passthru.updateScript = gitUpdater {
        allowedVersions = "^${lib.versions.major version}\\.";
        ignoredVersions = "(alpha|beta).*";
        rev-prefix = "jetty-";
        url = "https://github.com/jetty/jetty.project.git";
      };

      meta = {
        description = "Web server and javax.servlet container";
        homepage = "https://jetty.org/";
        changelog = "https://github.com/jetty/jetty.project/releases/tag/jetty-${version}";

        license = with lib.licenses; [
          asl20
          epl10
        ];

        sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];

        maintainers = with lib.maintainers; [
          emmanuelrosa
          anthonyroussel
        ];

        platforms = lib.platforms.all;
      };
    };

in
{
  jetty_11 = common {
    version = "11.0.26";
    hash = "sha256-uJgh/+/uGjchTgtoF38f7jIvbdrwdToAsqqVOlYtMIM=";
  };

  jetty_12 = common {
    version = "12.1.10";
    hash = "sha256-5/R4/mrmixhCfemqXbZcNwLSYY51p/IX+vT4jhGCqb4=";
  };
}
