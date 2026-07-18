{ fetchFromGitHub, testers, ... }:
{
  describe-tag = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    hash = "sha256-y7l+46lVP2pzJwGON5qEV0EoxWofRoWAym5q9VXvpc8=";
    name = "describe-tag-nix-source";
    owner = "NixOS";

    postCheckout = ''
      { git -C "$out" describe || echo "git describe failed"; } | tee "$out"/describe-output.txt
    '';

    repo = "nix";
    rev = "2.3.15";
  };

  dumb-http-signed-tag = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    name = "dumb-http-signed-tag-source";
    owner = "NixOS";
    repo = "nix";
    sha256 = "sha256-uZCaBo9rdWRO/AlQMvVVjpAwzYijB2H5KKQqde6eHkg=";
    tag = "2.9.2";
  };

  fetchTags = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    fetchTags = true;
    leaveDotGit = true;
    name = "fetchFromGitHub-fetch-tags-test";
    owner = "NixOS";

    postFetch = ''
      cd $out && git describe --tags --always > describe-output.txt 2>&1 || echo "git describe failed" > describe-output.txt
      # See https://github.com/NixOS/nixpkgs/issues/412967#issuecomment-2927452118
      rm -rf .git
    '';

    repo = "nix";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-y7l+46lVP2pzJwGON5qEV0EoxWofRoWAym5q9VXvpc8=";
  };

  leave-git = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    leaveDotGit = true;
    name = "leave-git-nix-source";
    owner = "NixOS";
    repo = "nix";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-VmQ38+lr+rNPaTnjjV41uC2XSN4fkfZAfytE2uKyLfo=";
  };

  rootDir = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    hash = "sha256-UhxHk4SrXYq7ZDMtXLig5SigpbITrVgkpFTmryuvpcM=";
    name = "fetchFromGitHub-with-rootdir";
    owner = "NixOS";
    repo = "nix";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    rootDir = "misc/systemd";
  };

  simple = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    hash = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
    name = "simple-nix-source";
    owner = "NixOS";
    repo = "nix";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
  };

  simple-tag = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    hash = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
    name = "simple-tag-nix-source";
    owner = "NixOS";
    repo = "nix";
    rev = "2.3.15";
  };

  sparseCheckout = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    name = "sparse-checkout-nix-source";
    owner = "NixOS";
    repo = "nix";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-g1PHGTWgAcd/+sXHo1o6AjVWCvC6HiocOfMbMh873LQ=";

    sparseCheckout = [
      "src"
      "tests"
    ];
  };

  sparseCheckoutNonConeMode = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    name = "sparse-checkout-non-cone-nix-source";
    nonConeMode = true;
    owner = "NixOS";
    repo = "nix";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-FknO6C/PSnMPfhUqObD4vsW4PhkwdmPa9blNzcNvJQ4=";

    sparseCheckout = [
      "src"
      "tests"
    ];
  };

  submodule-deep = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    deepClone = true;
    fetchSubmodules = true;
    name = "submodule-deep-source";
    owner = "pineapplehunter";
    # deepClone implies leaveDotGit, so delete the .git directory after
    # fetching to distinguish from the submodule-leave-git-deep test.
    postFetch = "rm -r $out/.git";
    repo = "nix-test-repo-with-submodule";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-3zWogs6EZBnzUfz6gBnigETTKGYl9KFKFgsy6Bl4DME=";
  };

  submodule-leave-git = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    fetchSubmodules = true;
    leaveDotGit = true;
    name = "submodule-leave-git-source";
    owner = "pineapplehunter";
    repo = "nix-test-repo-with-submodule";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-EC2PMEEtA7f5OFdsluHn7pi4QXhCZuFML8tib4pV7Ek=";
  };

  submodule-leave-git-deep = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    deepClone = true;
    fetchSubmodules = true;
    leaveDotGit = true;
    name = "submodule-leave-git-deep-source";
    owner = "pineapplehunter";
    repo = "nix-test-repo-with-submodule";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-ieYn9I/0RgeSwQkSqwKaU3RgjKFlRqMg7zw0Nvu3azA=";
  };

  submodule-simple = testers.invalidateFetcherByDrvHash fetchFromGitHub {
    fetchSubmodules = true;
    name = "submodule-simple-source";
    owner = "pineapplehunter";
    repo = "nix-test-repo-with-submodule";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-rmP8PQT0wJBopdtr/hsB7Y/L1G+ZPdHC2r9LB05Qrj4=";
  };
}
