# cd nixpkgs
# nix-build -A tests.testers.hasCmakeConfigModules
{
  lib,
  boost,
  eigen,
  mpi,
  runCommand,
  testers,
}:

lib.recurseIntoAttrs {

  boost-has-boost_mpi = testers.hasCmakeConfigModules {
    buildInputs = [ mpi ];

    moduleNames = [
      "boost_mpi"
    ];

    package = boost.override { useMpi = true; };
  };

  boost-no-versionCheck = testers.hasCmakeConfigModules {
    version = "1.2.3"; # Deliberately-incorrect version number

    moduleNames = [
      "Boost"
      "boost_math"
    ];

    package = boost;
    versionCheck = false;
  };

  boost-versions-match = testers.hasCmakeConfigModules {
    moduleNames = [
      "Boost"
      "boost_math"
    ];

    package = boost;
    versionCheck = true;
  };

  boost-versions-mismatch = testers.testBuildFailure (
    testers.hasCmakeConfigModules {
      version = "1.2.3"; # Deliberately-incorrect version number

      moduleNames = [
        "Boost"
        "boost_math"
      ];

      package = boost;
      versionCheck = true;
    }
  );

  boost_mpi-does-not-have-mpi = testers.testBuildFailure (
    testers.hasCmakeConfigModules {
      moduleNames = [
        "boost_mpi"
      ];

      package = boost.override { useMpi = true; };
    }
  );

  eigen-does-not-have-eigen = testers.testBuildFailure (
    testers.hasCmakeConfigModules {
      moduleNames = [ "eigen3" ];
      package = eigen;
    }
  );

  eigen-has-Eigen = testers.hasCmakeConfigModules {
    moduleNames = [ "Eigen3" ];
    package = eigen;
  };
}
