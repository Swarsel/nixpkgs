{
  lib,
  fetchurl,
  emptyFile,
  hello,
  jq,
  moreutils,
  testers,
  writeShellScriptBin,
  writeText,
  ...
}:
let
  testFlagAppending =
    args:
    testers.invalidateFetcherByDrvHash
      (fetchurl.override (previousArgs: {
        curl = (
          writeShellScriptBin "curl" ''
            set -eu -o pipefail
            hasFoo=
            hasBar=
            echo "curl-mock-expecting-flags: get flags: $*" >&2
            for arg; do
              case "$arg" in
              -V|--version)
                ${lib.getExe previousArgs.curl} "$arg"
                exit "$?"
                ;;
              --foo)
                echo "curl-mock-expecting-flags: \`--foo' found in the argument list passed to \`curl'." >&2
                hasFoo=1
                ;;
              --bar)
                echo "curl-mock-expecting-flags: \`--bar' found in the argument list passed to \`curl'." >&2
                hasBar=1
                ;;
              esac
            done
            if [[ -z "$hasFoo" ]]; then
              echo "ERROR: curl-mock-expecting-flags: \`--foo' missing in the argument list passed to \`curl'." >&2
            fi
            if [[ -z "$hasBar" ]]; then
              echo "ERROR: curl-mock-expecting-flags: \`--bar' missing in the argument list passed to \`curl'." >&2
            fi
            if [[ -n "$hasFoo" ]] && [[ -n "$hasBar" ]]; then
              touch $out
            else
              exit 1
            fi
          ''
        );
      }))
      (
        {
          hash = emptyFile.outputHash;
          recursiveHash = true; # aligned with emptyFile
          url = "https://www.example.com/source";
        }
        // args
      );
in
{
  flag-appending-curlOpts = testFlagAppending {
    curlOpts = "--foo --bar";
    name = "test-fetchurl-flag-appending-curlOpts";
  };

  flag-appending-curlOptsList = testFlagAppending {
    curlOptsList = [
      "--foo"
      "--bar"
    ];

    name = "test-fetchurl-flag-appending-curlOptsList";
  };

  flag-appending-netrcPhase-curlOpts = testFlagAppending {
    name = "test-fetchurl-flag-appending-netrcPhase-curlOpts";

    netrcPhase = ''
      touch netrc
      curlOpts="$curlOpts --foo --bar"
    '';
  };

  flag-appending-netrcPhase-curlOptsList = testFlagAppending {
    name = "test-fetchurl-flag-appending-netrcPhase-curlOptsList";

    netrcPhase = ''
      touch netrc
      curlOptsList+=("--foo" "--bar")
    '';
  };

  # Tests that hashedMirrors works
  hashedMirrors = testers.invalidateFetcherByDrvHash fetchurl {
    # No chance
    curlOptsList = [
      "--retry"
      "0"
    ];

    # A file with this hash is definitely on tarballs.nixos.org
    sha256 = "1j1y3cq6ys30m734axc0brdm2q9n2as4h32jws15r7w5fwr991km";
    # Make sure that we can only download from hashed mirrors
    url = "http://broken";
  };

  # Tests that we can send custom headers with spaces in them
  header =
    let
      headerValue = "Test '\" <- These are some quotes";
    in
    testers.invalidateFetcherByDrvHash fetchurl {
      curlOptsList = [
        "-H"
        "Hello: ${headerValue}"
      ];

      postFetch = ''
        ${jq}/bin/jq -r '.headers.Hello' $out | ${moreutils}/bin/sponge $out
      '';

      sha256 = builtins.hashString "sha256" (headerValue + "\n");
      url = "https://httpbin.org/headers";
    };

  # Tests that downloadToTemp works with hashedMirrors
  no-skipPostFetch = testers.invalidateFetcherByDrvHash fetchurl {
    # No chance
    curlOptsList = [
      "--retry"
      "0"
    ];

    downloadToTemp = true;
    # A file with this hash is definitely on tarballs.nixos.org
    sha256 = "1j1y3cq6ys30m734axc0brdm2q9n2as4h32jws15r7w5fwr991km";
    # Make sure that we can only download from hashed mirrors
    url = "http://broken";
    # Usually postFetch is needed with downloadToTemp to populate $out from
    # $downloadedFile, but here we know that because the URL is broken, it will
    # have to fallback to fetching the previously-built derivation from
    # tarballs.nixos.org, which provides pre-built derivation outputs.
  };

  showURLs-urls-mirrors = testers.invalidateFetcherByDrvHash fetchurl (finalAttrs: {
    hash =
      let
        hashAlgo = lib.head (lib.splitString "-" lib.fakeHash);
      in
      hashAlgo
      + ":"
      + builtins.hashString hashAlgo (
        lib.concatStringsSep " " (lib.concatMap fetchurl.resolveUrl finalAttrs.urls) + "\n"
      );

    name = "test-fetchurl-showURLs-urls-mirrors";
    showURLs = true;

    urls = [
      "http://broken"
    ]
    ++ hello.src.urls;
  });

  urls-mirrors = testers.invalidateFetcherByDrvHash fetchurl rec {
    hash = hello.src.outputHash;
    name = "test-fetchurl-urls-simple";

    postFetch = hello.postFetch or "" + ''
      if ! diff -u ${
        builtins.toFile "urls-resolved-by-eval" (
          lib.concatStringsSep "\n" (lib.concatMap fetchurl.resolveUrl urls) + "\n"
        )
      } <(printf '%s\n' "''${resolvedUrls[@]}"); then
        echo "ERROR: fetchurl: build-time-resolved URLs \`urls' differ from the evaluation-resolved URLs." >&2
        exit 1
      fi
    '';

    urls = [
      "http://broken"
    ]
    ++ hello.src.urls;
  };

  urls-simple = testers.invalidateFetcherByDrvHash fetchurl {
    hash = hello.src.outputHash;
    name = "test-fetchurl-urls-simple";

    urls = [
      "http://broken"
      hello.src.resolvedUrl
    ];
  };
}
