{ stdenv, callPackage }:

rec {
  mlton20130715 = callPackage ./20130715.nix { };

  mlton20180207 = callPackage ./from-git-source.nix {
    version = "20180207";
    hash = "sha256-SuAhZRhmW+8l50aI0SSLv7lRC/iJRmKY+i30EptoLQM=";
    mltonBootstrap = mlton20180207Binary;
    rev = "on-20180207-release";
  };

  mlton20180207Binary = callPackage ./20180207-binary.nix { };

  mlton20210117 = callPackage ./from-git-source.nix {
    version = "20210117";
    hash = "sha256-rqL8lnzVVR+5Hc7sWXK8dCXN92dU76qSoii3/4StODM=";
    mltonBootstrap = mlton20210117Binary;
    rev = "on-20210117-release";
  };

  mlton20210117Binary = callPackage ./20210117-binary.nix { };

  mlton20241230 = callPackage ./from-git-source.nix {
    version = "20241230";
    # https://github.com/MLton/mlton/issues/631
    doCheck = !(stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isDarwin);
    hash = "sha256-gJUzav2xH8C4Vy5FuqN73Z6lPMSPQgJApF8LgsJXRWo=";
    mltonBootstrap = mlton20241230Binary;
    rev = "on-20241230-release";
  };

  mlton20241230Binary = callPackage ./20241230-binary.nix { };

  mltonHEAD = callPackage ./from-git-source.nix {
    version = "HEAD";
    # https://github.com/MLton/mlton/issues/631
    doCheck = !(stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isDarwin);
    hash = "sha256-nWR7ZaXfKxeXfZ9IHipAQ39ASVtva4BeDHP3Zq8mqPo=";
    mltonBootstrap = mlton20241230Binary;
    rev = "61baac7108fbd91413f0537b7a42d9a1023455f4";
  };
}
