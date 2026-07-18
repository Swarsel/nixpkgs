{
  pkgs ? import <nixpkgs> { },
}:
## we default to importing <nixpkgs> here, so that you can use
## a simple shell command to insert new hashes into this file
## e.g. with emacs C-u M-x shell-command
##
##     nix-prefetch-url sources.nix -A {stable{,.mono,.gecko64,.gecko32}, unstable, staging, winetricks}

# here we wrap fetchurl and fetchFromGitHub, in order to be able to pass additional args around it
let
  fetchurl = args@{ hash, url, ... }: pkgs.fetchurl { inherit url hash; } // args;
  fetchFromGitHub =
    args@{
      hash,
      owner,
      repo,
      rev,
      ...
    }:
    pkgs.fetchFromGitHub {
      inherit
        owner
        repo
        rev
        hash
        ;
    }
    // args;
  fetchFromGitLab =
    args@{
      domain,
      hash,
      owner,
      repo,
      rev,
      ...
    }:
    pkgs.fetchFromGitLab {
      inherit
        domain
        owner
        repo
        rev
        hash
        ;
    }
    // args;

  updateScriptPreamble = ''
    set -eou pipefail
    PATH=${
      with pkgs;
      lib.makeBinPath [
        common-updater-scripts
        coreutils
        curl
        gnugrep
        gnused
        jq
        nix
      ]
    }
    sources_file=./pkgs/applications/emulators/wine/sources.nix
    source ${./update-lib.sh}
  '';

  # Needed for wine versions < 10.2 to fix compatibility with binutils 2.44
  # https://github.com/NixOS/nixpkgs/issues/399714
  # https://bugs.winehq.org/show_bug.cgi?id=57819
  # https://gitlab.winehq.org/wine/wine/-/merge_requests/7328
  patches-binutils-2_44-fix-wine-older-than-10_2 = [
    (pkgs.fetchpatch {
      hash = "sha256-PvFom9NJ32XZO1gYor9Cuk8+eaRFvmG572OAtNx1tks=";
      name = "ntdll-use-signed-type";
      url = "https://gitlab.winehq.org/wine/wine/-/commit/fd59962827a715d321f91c9bdb43f3e61f9ebbc.patch";
    })
    (pkgs.fetchpatch {
      hash = "sha256-vA58SfAgCXoCT+NB4SRHi85AnI4kj9S2deHGp4L36vI=";
      name = "winebuild-avoid using-idata-section";
      url = "https://gitlab.winehq.org/wine/wine/-/commit/c9519f68ea04915a60704534ab3afec5ec1b8fd7.patch";
    })
  ];

  # Fix build with GCC 15
  # https://bugs.winehq.org/show_bug.cgi?id=58191
  patches-add-truncf-to-the-import-library = [
    (pkgs.fetchpatch {
      hash = "sha256-mn0fRZ840MYk1WZsBLcachUzyNmBUSlvf50t9jFGXp0=";
      name = "add-truncf-to-the-import-library.patch";
      url = "https://gitlab.winehq.org/wine/wine/-/commit/ed66bd5c97ecc17c42a4942dafac7d406c1e5120.patch";
    })
  ];

  patches-add-dll-accept-device-paths-wine-older-than-11_1 = [
    (pkgs.fetchpatch {
      hash = "sha256-2726u9/vhhx39Tq7vOw24hslmeyZZEbxRRqe7JMFvCU";
      name = "add-dll-accept-device-paths";
      url = "https://gitlab.winehq.org/wine/wine/-/commit/401910ae25a11032f2da7baa1666d71e8bca2496.patch";
    })
  ];

  inherit (pkgs) writeShellScript;
in
rec {

  stable = fetchurl rec {
    version = "11.0";

    patches = [
      # Also look for root certificates at $NIX_SSL_CERT_FILE
      ./cert-path.patch
    ]
    ++ patches-add-dll-accept-device-paths-wine-older-than-11_1;

    ## see http://wiki.winehq.org/Gecko
    gecko32 = fetchurl rec {
      version = "2.47.4";
      hash = "sha256-Js7MR3BrCRkI9/gUvdsHTGG+uAYzGOnvxaf3iYV3k9Y=";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.msi";
    };

    gecko64 = fetchurl rec {
      version = "2.47.4";
      hash = "sha256-5ZC32YijLWqkzx2Ko6o9M3Zv3Uz0yJwtzCCV7LKNBm8=";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86_64.msi";
    };

    hash = "sha256-wHpoV5M8H8YN/1RI1585ySSBwenbWqYo250DWERuBwE=";

    ## see http://wiki.winehq.org/Mono
    mono = fetchurl rec {
      version = "10.0.0";
      hash = "sha256-26ynPl0J96OnwVetBCia+cpHw87XAS1GVEpgcEaQK4c=";
      url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
    };

    updateScript = writeShellScript "update-wine-stable" ''
      ${updateScriptPreamble}
      major=''${UPDATE_NIX_OLD_VERSION%%.*}
      latest_stable=$(get_latest_wine_version "$major.0")

      # Can't use autobump on stable because we don't want the path
      # <source/7.0/wine-7.0.tar.xz> to become <source/7.0.1/wine-7.0.1.tar.xz>.
      if [[ "$UPDATE_NIX_OLD_VERSION" != "$latest_stable" ]]; then
          set_version_and_hash stable "$latest_stable" "$(nix-prefetch-url "$wine_url_base/source/$major.0/wine-$latest_stable.tar.xz")"
      fi

      do_update
    '';

    url = "https://dl.winehq.org/wine/source/11.0/wine-${version}.tar.xz";
  };

  unstable = fetchurl rec {
    # NOTE: Don't forget to change the hash for staging as well.
    version = "11.12";

    patches = [
      # Also look for root certificates at $NIX_SSL_CERT_FILE
      ./cert-path.patch
    ];

    ## see http://wiki.winehq.org/Gecko
    gecko32 = fetchurl rec {
      version = "2.47.4";
      hash = "sha256-Js7MR3BrCRkI9/gUvdsHTGG+uAYzGOnvxaf3iYV3k9Y=";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.msi";
    };

    gecko64 = fetchurl rec {
      version = "2.47.4";
      hash = "sha256-5ZC32YijLWqkzx2Ko6o9M3Zv3Uz0yJwtzCCV7LKNBm8=";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86_64.msi";
    };

    hash = "sha256-07wJEZLZhYRsnyAGXMgfITMfAeIrc2sTHjRJ4TBmcbw=";

    ## see http://wiki.winehq.org/Mono
    mono = fetchurl rec {
      version = "11.2.0";
      hash = "sha256-tFJWeefaMNRljOuFc5y8VcdxeRBUq7tLMVL+lt7QuJc=";
      url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
    };

    # see https://gitlab.winehq.org/wine/wine-staging
    staging = fetchFromGitLab {
      inherit version;
      disabledPatchsets = [ ];
      domain = "gitlab.winehq.org";
      hash = "sha256-3pE/RVUvH56z9Ilumokl7nNMrhfksuUWzKq6k8behW4=";
      owner = "wine";
      repo = "wine-staging";
      rev = "v${version}";
    };

    updateScript = writeShellScript "update-wine-unstable" ''
      ${updateScriptPreamble}
      major=''${UPDATE_NIX_OLD_VERSION%%.*}
      latest_unstable=$(get_latest_wine_version "$major.x")
      latest_gecko=$(get_latest_lib_version wine-gecko)
      latest_mono=$(get_latest_lib_version wine-mono)

      update_staging() {
          staging_url=$(get_source_attr unstable.staging.url)
          set_source_attr unstable.staging hash "\"$(to_sri "$(nix-prefetch-url --unpack "''${staging_url//$1/$2}")")\""
      }

      autobump unstable "$latest_unstable" "" update_staging
      autobump unstable.gecko32 "$latest_gecko"
      autobump unstable.gecko64 "$latest_gecko"
      autobump unstable.mono "$latest_mono"

      do_update
    '';

    url = "https://dl.winehq.org/wine/source/11.x/wine-${version}.tar.xz";
  };

  wayland = pkgs.lib.warnOnInstantiate "building wine with `wineRelease = \"wayland\"` is deprecated. Wine now builds with the wayland driver by default." stable; # added 2025-01-23

  winetricks = fetchFromGitHub rec {
    # https://github.com/Winetricks/winetricks/releases
    version = "20260125";
    hash = "sha256-uIBVESebsH7rXnxWd/qlrZxcG7Y486PctHzcLz29HDk=";
    owner = "Winetricks";
    repo = "winetricks";
    rev = version;

    updateScript = writeShellScript "update-winetricks" ''
      ${updateScriptPreamble}
      winetricks_repourl=$(get_source_attr winetricks.gitRepoUrl)

      latest_winetricks=$(list-git-tags --url="$winetricks_repourl" | grep -E '^[0-9]{8}$' | sort --reverse --numeric-sort | head -n 1)

      autobump winetricks "$latest_winetricks" 'nix-prefetch-url --unpack'

      do_update
    '';
  };

  yabridge = fetchurl rec {
    # NOTE: This is a pinned version with staging patches; don't forget to update them as well
    version = "9.21";

    patches = [
      # Also look for root certificates at $NIX_SSL_CERT_FILE
      ./cert-path.patch
    ]
    ++ patches-binutils-2_44-fix-wine-older-than-10_2
    ++ patches-add-truncf-to-the-import-library;

    ## see http://wiki.winehq.org/Gecko
    gecko32 = fetchurl rec {
      version = "2.47.4";
      hash = "sha256-Js7MR3BrCRkI9/gUvdsHTGG+uAYzGOnvxaf3iYV3k9Y=";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86.msi";
    };

    gecko64 = fetchurl rec {
      version = "2.47.4";
      hash = "sha256-5ZC32YijLWqkzx2Ko6o9M3Zv3Uz0yJwtzCCV7LKNBm8=";
      url = "https://dl.winehq.org/wine/wine-gecko/${version}/wine-gecko-${version}-x86_64.msi";
    };

    hash = "sha256-REK0f/2bLqRXEA427V/U5vTYKdnbeaJeYFF1qYjKL/8=";

    ## see http://wiki.winehq.org/Mono
    mono = fetchurl rec {
      version = "9.3.0";
      hash = "sha256-bKLArtCW/57CD69et2xrfX3oLZqIdax92fB5O/nD/TA=";
      url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
    };

    # see https://gitlab.winehq.org/wine/wine-staging
    staging = fetchFromGitLab {
      inherit version;
      disabledPatchsets = [ ];
      domain = "gitlab.winehq.org";
      hash = "sha256-FDNszRUvM1ewE9Ij4EkuihaX0Hf0eTb5r7KQHMdCX3U=";
      owner = "wine";
      repo = "wine-staging";
      rev = "v${version}";
    };

    url = "https://dl.winehq.org/wine/source/9.x/wine-${version}.tar.xz";
  };
}
