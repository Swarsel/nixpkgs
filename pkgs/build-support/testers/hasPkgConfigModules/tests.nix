# cd nixpkgs
# nix-build -A tests.testers.hasPkgConfigModules
{
  lib,
  miniz,
  openssl,
  runCommand,
  testers,
  zlib,
}:

lib.recurseIntoAttrs {

  miniz-no-versionCheck = testers.hasPkgConfigModules {
    version = "1.2.3"; # Deliberately-incorrect version number
    package = miniz;
  };

  miniz-versions-match = testers.hasPkgConfigModules {
    package = miniz;
    versionCheck = true;
  };

  miniz-versions-mismatch = testers.testBuildFailure (
    testers.hasPkgConfigModules {
      version = "1.2.3"; # Deliberately-incorrect version number
      package = miniz;
      versionCheck = true;
    }
  );

  openssl-has-all-meta-pkgConfigModules = testers.hasPkgConfigModules {
    package = openssl;
  };

  openssl-has-openssl = testers.hasPkgConfigModules {
    moduleNames = [ "openssl" ];
    package = openssl;
  };

  zlib-does-not-have-ylib =
    runCommand "zlib-does-not-have-ylib"
      {
        failed = testers.testBuildFailure (
          testers.hasPkgConfigModules {
            moduleNames = [ "ylib" ];
            package = zlib;
          }
        );
      }
      ''
        echo 'it logs a relevant error message'
        {
          grep -F "pkg-config module ylib was not found" $failed/testBuildFailure.log
        }

        echo 'it logs which pkg-config modules are available, to be helpful'
        {
          # grep -v: the string zlib does also occur in a store path in an earlier message, which isn't particularly helpful
          grep -v "checking pkg-config module" < $failed/testBuildFailure.log \
            | grep -F "zlib"
        }

        # done
        touch $out
      '';

  zlib-has-meta-pkgConfigModules = testers.hasPkgConfigModules {
    package = zlib;
  };

  zlib-has-zlib = testers.hasPkgConfigModules {
    moduleNames = [ "zlib" ];
    package = zlib;
  };

}
