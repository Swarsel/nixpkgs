{ fetchYarnDeps, testers, ... }:

{
  file = testers.invalidateFetcherByDrvHash fetchYarnDeps {
    sha256 = "sha256-BPuyQVCbdpFL/iRhmarwWAmWO2NodlVCOY9JU+4pfa4=";
    yarnLock = ./file.lock;
  };

  gitDep = testers.invalidateFetcherByDrvHash fetchYarnDeps {
    sha256 = "sha256-f90IiEzHDiBdswWewRBHcJfqqpPipaMg8N0DVLq2e8Q=";
    yarnLock = ./git.lock;
  };

  gitUrlDep = testers.invalidateFetcherByDrvHash fetchYarnDeps {
    sha256 = "sha256-VPnyqN6lePQZGXwR7VhbFnP7/0/LB621RZwT1F+KzVQ=";
    yarnLock = ./giturl.lock;
  };

  githubDep = testers.invalidateFetcherByDrvHash fetchYarnDeps {
    sha256 = "sha256-DIKrhDKoqm7tHZmcuh9eK9VTqp6BxeW0zqDUpY4F57A=";
    yarnLock = ./github.lock;
  };

  githubReleaseDep = testers.invalidateFetcherByDrvHash fetchYarnDeps {
    sha256 = "sha256-g+y/H6k8LZ+IjWvkkwV7JhKQH1ycfeqzsIonNv4fDq8=";
    yarnLock = ./github-release.lock;
  };

  simple = testers.invalidateFetcherByDrvHash fetchYarnDeps {
    sha256 = "sha256-FRrt8BixleILmFB2ZV8RgPNLqgS+dlH5nWoPgeaaNQ8=";
    yarnLock = ./simple.lock;
  };
}
