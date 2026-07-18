{
  lib,
  cacert,
  closureInfo,
  fetchgit,
  jq,
  nix,
  nix-prefetch-git,
  runCommand,
  testers,
  ...
}:
{
  # Make sure that if an expected hash is given and the corresponding store path exists already, no fetch is done
  cached-prefetch-avoids-fetch =
    let
      name = "cached-prefetch-avoids-fetch";
      url = "https://github.com/NixOS/nix";
      rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
      sha256 = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
      fetched = fetchgit {
        inherit
          name
          url
          rev
          sha256
          ;
      };
    in
    runCommand "cached-prefetch-avoids-fetch"
      {
        nativeBuildInputs = [
          nix-prefetch-git
          nix
        ];
      }
      ''
        export NIX_REMOTE=local?root=$(mktemp -d)
        nix-store --load-db < ${closureInfo { rootPaths = fetched; }}/registration
        nix-prefetch-git --name "${name}" "${url}" "${rev}" "${sha256}" > $out
      '';

  collect-rev = testers.invalidateFetcherByDrvHash fetchgit {
    hash = "sha256-AUTX1K7J5+fojvKYJacXYVV5kio3hrWYz5MCekO6h68=";
    name = "collect-rev-nix-source";

    postCheckout = ''
      git -C "$out" rev-parse HEAD | tee "$out/revision.txt"
    '';

    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    url = "https://github.com/NixOS/nix";
  };

  describe-tag = testers.invalidateFetcherByDrvHash fetchgit {
    hash = "sha256-y7l+46lVP2pzJwGON5qEV0EoxWofRoWAym5q9VXvpc8=";
    name = "describe-tag-nix-source";

    postCheckout = ''
      { git -C "$out" describe || echo "git describe failed"; } | tee "$out"/describe-output.txt
    '';

    tag = "2.3.15";
    url = "https://github.com/NixOS/nix";
  };

  dumb-http-signed-tag = testers.invalidateFetcherByDrvHash fetchgit {
    name = "dumb-http-signed-tag-source";
    rev = "v3.0.14";
    sha256 = "sha256-bd0Lx75Gd1pcBJtwz5WGki7XoYSpqhinCT3a77wpY2c=";
    url = "https://git.scottworley.com/pub/git/pinch";
  };

  fetchTags = testers.invalidateFetcherByDrvHash fetchgit {
    fetchTags = true;
    leaveDotGit = true;
    name = "fetchgit-fetch-tags-test";

    postFetch = ''
      cd $out && git describe --tags --always > describe-output.txt 2>&1 || echo "git describe failed" > describe-output.txt
      # See https://github.com/NixOS/nixpkgs/issues/412967#issuecomment-2927452118
      rm -rf .git
    '';

    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-y7l+46lVP2pzJwGON5qEV0EoxWofRoWAym5q9VXvpc8=";
    url = "https://github.com/NixOS/nix";
  };

  leave-git = testers.invalidateFetcherByDrvHash fetchgit {
    leaveDotGit = true;
    name = "leave-git-nix-source";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-VmQ38+lr+rNPaTnjjV41uC2XSN4fkfZAfytE2uKyLfo=";
    url = "https://github.com/NixOS/nix";
  };

  prefetch-git-no-add-path =
    testers.invalidateFetcherByDrvHash
      (
        {
          hash,
          name,
          rev,
          url,
          ...
        }:
        runCommand name
          {
            inherit url rev;

            buildInputs = [
              nix-prefetch-git
              nix
              cacert
              jq
            ];

            outputHash = hash;
            outputHashAlgo = null;
            outputHashMode = "recursive";
          }
          ''
            store_root="$(mktemp -d)"
            prefetch() { NIX_REMOTE="local?root=$store_root" nix-prefetch-git $@ "$url" --rev "$rev" | jq -r .path; }
            path="$(prefetch --no-add-path)"
            if test -e "$store_root/$path"; then
              echo "$path exists in $NIX_REMOTE when it shouldn't" >&2
              exit 1
            fi
            path_added="$(prefetch)"
            if ! test -e "$store_root/$path"; then
              echo "$path_added doesn't exist in NIX_REMOTE when it should" >&2
              exit 1
            fi
            if test "$path" != "$path_added"; then
              echo "Paths are different with and without --no-add-path: $path != $path_added" >&2
              exit 1
            fi
            cp -r "$store_root/$path_added" "$out"
          ''
      )
      {
        hash = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
        name = "nix-prefetch-git-no-add-path";
        rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
        url = "https://github.com/NixOS/nix";
      };

  rootDir = testers.invalidateFetcherByDrvHash fetchgit {
    name = "fetchgit-with-rootdir";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    rootDir = "misc/systemd";
    sha256 = "sha256-UhxHk4SrXYq7ZDMtXLig5SigpbITrVgkpFTmryuvpcM=";
    url = "https://github.com/NixOS/nix";
  };

  simple = testers.invalidateFetcherByDrvHash fetchgit {
    name = "simple-nix-source";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
    url = "https://github.com/NixOS/nix";
  };

  simple-tag = testers.invalidateFetcherByDrvHash fetchgit {
    hash = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
    name = "simple-tag-nix-source";
    tag = "2.3.15";
    url = "https://github.com/NixOS/nix";
  };

  sparseCheckout = testers.invalidateFetcherByDrvHash fetchgit {
    name = "sparse-checkout-nix-source";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-g1PHGTWgAcd/+sXHo1o6AjVWCvC6HiocOfMbMh873LQ=";

    sparseCheckout = [
      "src"
      "tests"
    ];

    url = "https://github.com/NixOS/nix";
  };

  sparseCheckoutNonConeMode = testers.invalidateFetcherByDrvHash fetchgit {
    name = "sparse-checkout-non-cone-nix-source";
    nonConeMode = true;
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-FknO6C/PSnMPfhUqObD4vsW4PhkwdmPa9blNzcNvJQ4=";

    sparseCheckout = [
      "src"
      "tests"
    ];

    url = "https://github.com/NixOS/nix";
  };

  submodule-deep = testers.invalidateFetcherByDrvHash fetchgit {
    deepClone = true;
    fetchSubmodules = true;
    name = "submodule-deep-source";
    # deepClone implies leaveDotGit, so delete the .git directory after
    # fetching to distinguish from the submodule-leave-git-deep test.
    postFetch = "rm -r $out/.git";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-3zWogs6EZBnzUfz6gBnigETTKGYl9KFKFgsy6Bl4DME=";
    url = "https://github.com/pineapplehunter/nix-test-repo-with-submodule";
  };

  submodule-leave-git = testers.invalidateFetcherByDrvHash fetchgit {
    fetchSubmodules = true;
    leaveDotGit = true;
    name = "submodule-leave-git-source";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-EC2PMEEtA7f5OFdsluHn7pi4QXhCZuFML8tib4pV7Ek=";
    url = "https://github.com/pineapplehunter/nix-test-repo-with-submodule";
  };

  submodule-leave-git-deep = testers.invalidateFetcherByDrvHash fetchgit {
    deepClone = true;
    fetchSubmodules = true;
    leaveDotGit = true;
    name = "submodule-leave-git-deep-source";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-ieYn9I/0RgeSwQkSqwKaU3RgjKFlRqMg7zw0Nvu3azA=";
    url = "https://github.com/pineapplehunter/nix-test-repo-with-submodule";
  };

  submodule-revision-count = testers.invalidateFetcherByDrvHash fetchgit {
    deepClone = true;
    fetchSubmodules = true;
    hash = "sha256-ok1e6Pb0fII5TF8HXF8DXaRGSoq7kgRCoXqSEauh1wk=";
    leaveDotGit = false;
    name = "submodule-revision-count-source";

    postCheckout = ''
      { git -C "$out" rev-list --count HEAD || echo "git rev-list failed"; } | tee "$out/revision_count.txt"
      { git -C "$out/nix-test-repo-submodule" rev-list --count HEAD || echo "git rev-list failed"; } | tee "$out/nix-test-repo-submodule/revision_count.txt"
    '';

    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    url = "https://github.com/pineapplehunter/nix-test-repo-with-submodule";
  };

  submodule-simple = testers.invalidateFetcherByDrvHash fetchgit {
    fetchSubmodules = true;
    name = "submodule-simple-source";
    rev = "26473335b84ead88ee0a3b649b1c7fa4a91cfd4a";
    sha256 = "sha256-rmP8PQT0wJBopdtr/hsB7Y/L1G+ZPdHC2r9LB05Qrj4=";
    url = "https://github.com/pineapplehunter/nix-test-repo-with-submodule";
  };

  withGitConfig = testers.invalidateFetcherByDrvHash fetchgit {
    gitConfigFile = lib.toFile "gitconfig" (
      lib.generators.toGitINI {
        url."https://github.com".insteadOf = "https://doesntexist.forsure";
      }
    );

    name = "fetchgit-with-config";
    rev = "9d9dbe6ed05854e03811c361a3380e09183f4f4a";
    sha256 = "sha256-7DszvbCNTjpzGRmpIVAWXk20P0/XTrWZ79KSOGLrUWY=";
    url = "https://doesntexist.forsure/NixOS/nix";
  };
}
