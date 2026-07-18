{
  lib,
  cacert,
  config,
  git,
  git-lfs,
  stdenvNoCC,
}:

let
  urlToName =
    {
      append,
      rev,
      url,
    }:
    let
      shortRev = lib.sources.shortRev rev;
      appendShort = lib.optionalString ((builtins.match "[a-f0-9]*" rev) != null) "-${shortRev}";
    in
    "${lib.sources.urlToName url}${if append == "" then appendShort else append}";

  getRevWithTag =
    {
      rev ? null,
      tag ? null,
    }:
    if tag != null && rev != null then
      throw "fetchgit requires one of either `rev` or `tag` to be provided (not both)."
    else if tag != null then
      "refs/tags/${tag}"
    else if rev != null then
      rev
    else
      # FIXME fetching HEAD if no rev or tag is provided is problematic at best
      "HEAD";
in

lib.makeOverridable (
  lib.extendMkDerivation {
    constructDrv = stdenvNoCC.mkDerivation;

    excludeDrvArgNames = [
      # Additional stdenv.mkDerivation arguments from derived fetchers.
      "derivationArgs"

      # Hashes, handled by `lib.fetchers.withNormalizedHash`
      # whose outputs contain outputHash* attributes.
      # Use `hash` when overriding with `<pkg>.overrideAttrs`.
      "sha256"
    ];

    extendDrvArgs =
      finalAttrs:
      lib.fetchers.withNormalizedHash { } (
        # NOTE Please document parameter additions or changes in
        #   ../../../doc/build-helpers/fetchers.chapter.md
        {
          url,
          allowedRequisites ? null,
          branchName ? null,
          deepClone ? false,
          # Additional stdenvNoCC.mkDerivation arguments.
          # It is typically for derived fetchers to pass down additional arguments,
          # and the specified arguments have lower precedence than other mkDerivation arguments.
          derivationArgs ? { },
          fetchLFS ? false,
          fetchSubmodules ? true,
          # fetch all tags after tree (useful for git describe)
          fetchTags ? false,
          # GIT_CONFIG_GLOBAL (as a file)
          gitConfigFile ? config.gitConfigFile,
          # When null, will default to: `deepClone || fetchTags`
          leaveDotGit ? null,
          meta ? { },
          name ? urlToName {
            inherit url;
            # when rootDir is specified, avoid invalidating the result when rev changes
            append = if rootDir != "" then "-${lib.strings.sanitizeDerivationName rootDir}" else "";
            rev = lib.revOrTag finalAttrs.revCustom finalAttrs.tag;
          },
          nativeBuildInputs ? [ ],
          # Impure env vars (https://nixos.org/nix/manual/#sec-advanced-attributes)
          # needed for netrcPhase
          netrcImpureEnvVars ? [ ],
          # Shell code to build a netrc file for BASIC auth
          netrcPhase ? null,
          # When null, will default to: `rootDir != ""`
          nonConeMode ? null,
          outputHash ? lib.fakeHash,
          outputHashAlgo ? null,
          passthru ? { },
          # Shell code executed after `git checkout` and before .git directory removal/sanitization.
          postCheckout ? "",
          # Shell code executed after the file has been fetched
          # successfully. This can do things like check or transform the file.
          postFetch ? "",
          # Shell code executed before the file has been fetched.  This, in
          # particular, can do things like set NIX_PREFETCH_GIT_CHECKOUT_HOOK to
          # run operations between the checkout completing and deleting the .git
          # directory.
          preFetch ? "",
          preferLocalBuild ? true,
          rev ? null,
          # make this subdirectory the root of the result
          rootDir ? "",
          # When null, will default to: `lib.optional (rootdir != "") rootdir`
          sparseCheckout ? null,
          tag ? null,
        }:

        /*
          NOTE:
          fetchgit has one problem: git fetch only works for refs.
          This is because fetching arbitrary (maybe dangling) commits creates garbage collection risks
          and checking whether a commit belongs to a ref is expensive. This may
          change in the future when some caching is added to git (?)
          Usually refs are either tags (refs/tags/*) or branches (refs/heads/*)
          Cloning branches will make the hash check fail when there is an update.
          But not all patches we want can be accessed by tags.

          The workaround is getting the last n commits so that it's likely that they
          still contain the hash we want.

          for now : increase depth iteratively (TODO)

          real fix: ask git folks to add a
          git fetch $HASH contained in $BRANCH
          facility because checking that $HASH is contained in $BRANCH is less
          expensive than fetching --depth $N.
          Even if git folks implemented this feature soon it may take years until
          server admins start using the new version?
        */

        let
          finalHashHasColon = lib.hasInfix ":" finalAttrs.hash;
          finalHashColonMatch = lib.match "([^:]+)[:](.*)" finalAttrs.hash;
        in

        derivationArgs
        // {
          inherit name;

          inherit
            url
            fetchLFS
            fetchSubmodules
            deepClone
            branchName
            preFetch
            postCheckout
            postFetch
            fetchTags
            rootDir
            gitConfigFile
            ;

          inherit tag;
          inherit preferLocalBuild;

          nativeBuildInputs = [
            git
            cacert
          ]
          ++ lib.optionals fetchLFS [ git-lfs ]
          ++ nativeBuildInputs;

          env = {
            NIX_PREFETCH_GIT_CHECKOUT_HOOK = finalAttrs.postCheckout;
          };

          __structuredAttrs = true;
          builder = ./builder.sh;
          fetcher = ./nix-prefetch-git;

          hash =
            if outputHashAlgo == null || outputHash == "" || lib.hasPrefix outputHashAlgo outputHash then
              outputHash
            else
              "${outputHashAlgo}:${outputHash}";

          impureEnvVars =
            lib.fetchers.proxyImpureEnvVars
            ++ netrcImpureEnvVars
            ++ [
              "GIT_PROXY_COMMAND"
              "NIX_GIT_SSL_CAINFO"
              "SOCKS_SERVER"

              # This is a parameter intended to be set by setup hooks or preFetch
              # scripts that want per-URL control over HTTP proxies used by Git
              # (if per-URL control isn't needed, `http_proxy` etc. will
              # suffice). It must be a whitespace-separated (with backslash as an
              # escape character) list of pairs like this:
              #
              #   http://domain1/path1 proxy1 https://domain2/path2 proxy2
              #
              # where the URLs are as documented in the `git-config` manual page
              # under `http.<url>.*`, and the proxies are as documented on the
              # same page under `http.proxy`.
              "FETCHGIT_HTTP_PROXIES"
            ];

          leaveDotGit =
            if leaveDotGit != null then
              assert fetchTags -> leaveDotGit;
              assert rootDir != "" -> !leaveDotGit;
              leaveDotGit
            else
              deepClone || fetchTags;

          nonConeMode = lib.defaultTo (finalAttrs.rootDir != "") nonConeMode;

          outputChecks.out = {
            ${if allowedRequisites != null then "allowedRequisites" else null} = allowedRequisites;
          };

          outputHash =
            if finalAttrs.hash == "" then
              lib.fakeHash
            else if finalHashHasColon then
              lib.elemAt finalHashColonMatch 1
            else
              finalAttrs.hash;

          outputHashAlgo = if finalHashHasColon then lib.head finalHashColonMatch else null;
          outputHashMode = "recursive";

          postHook =
            if netrcPhase == null then
              null
            else
              ''
                ${netrcPhase}
                # required that git uses the netrc file
                mv {,.}netrc
                export NETRC=$PWD/.netrc
                export HOME=$PWD
              '';

          rev = getRevWithTag {
            inherit (finalAttrs) tag;
            rev = finalAttrs.revCustom;
          };

          revCustom = rev;

          sparseCheckout =
            let
              default = lib.optional (finalAttrs.rootDir != "") finalAttrs.rootDir;
            in
            lib.defaultTo default sparseCheckout;

          sparseCheckoutText =
            # Changed to throw on 2023-06-04
            assert (
              lib.isList finalAttrs.sparseCheckout
              || throw "Please provide directories/patterns for sparse checkout as a list of strings. Passing a (multi-line) string is not supported any more."
            );
            assert finalAttrs.nonConeMode -> (finalAttrs.sparseCheckout != [ ]);
            # git-sparse-checkout(1) says:
            # > When the --stdin option is provided, the directories or patterns are read
            # > from standard in as a newline-delimited list instead of from the arguments.
            builtins.concatStringsSep "\n" finalAttrs.sparseCheckout;

          passthru = {
            gitRepoUrl = url;
          }
          // passthru;

          meta = meta // {
            identifiers = {
              purlParts = {
                # https://github.com/package-url/purl-spec/blob/18fd3e395dda53c00bc8b11fe481666dc7b3807a/types-doc/generic-definition.md
                spec = "${name}?vcs_url=${url}@${(lib.revOrTag rev tag)}";
                type = "generic";
              };
            }
            // meta.identifiers or { };
          };
        }
      );

    # No ellipsis.
    inheritFunctionArgs = false;
  }
)
// {
  inherit getRevWithTag;
}
