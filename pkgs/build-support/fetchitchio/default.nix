{
  lib,
  cacert,
  python3,
  stdenvNoCC,
}:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "derivationArgs"
    "sha1"
    "sha256"
    "sha512"
  ];

  extendDrvArgs =
    finalAttrs:
    lib.fetchers.withNormalizedHash { } (
      {
        # The game store page URL in the format of https://{author}.itch.io/{game}
        gameUrl,
        # The upload ID of the downloadable file.
        # To get the upload ID, look at the request URL when you download it.
        upload,
        # The name of the environment variable that contains the itch.io API key.
        # The environment variable needs to be set for the nix building process,
        # which is nix-daemon for multi-user mode.
        apiKeyVar ? "NIX_ITCHIO_API_KEY",
        derivationArgs ? { },
        endpoint ? "https://api.itch.io",
        # The extra message printed when the API key is not provided
        # or when the account of the API key did not purchase the game.
        extraMessage ? null,
        impureEnvVars ? [ ],
        meta ? { },
        # Derivation name.
        name ? null,
        nativeBuildInputs ? [ ],
        outputHash ? lib.fakeHash,
        outputHashAlgo ? null,
        passthru ? { },
        postFetch ? "",
        preFetch ? "",
        preferLocalBuild ? true,
        # Show the download URL without actually downloading it, for testing purposes.
        # Notice that this can potentially leak the API key.
        showUrl ? false,
      }:
      let
        finalHashHasColon = lib.hasInfix ":" finalAttrs.hash;
        finalHashColonMatch = lib.match "([^:]+)[:](.*)" finalAttrs.hash;
      in
      derivationArgs
      // {
        inherit preferLocalBuild;

        inherit
          endpoint
          apiKeyVar
          gameUrl
          extraMessage
          showUrl
          preFetch
          postFetch
          ;

        nativeBuildInputs = [
          cacert
          python3
        ]
        ++ nativeBuildInputs;

        __structuredAttrs = true;

        builder = builtins.toFile "builder.sh" ''
          source "$NIX_ATTRS_SH_FILE"
          runHook preFetch
          python ${./fetchitchio.py}
          runHook postFetch
        '';

        hash =
          if outputHashAlgo == null || outputHash == "" || lib.hasPrefix outputHashAlgo outputHash then
            outputHash
          else
            "${outputHashAlgo}:${outputHash}";

        impureEnvVars =
          lib.fetchers.proxyImpureEnvVars
          ++ [
            apiKeyVar
            "NIX_CONNECT_TIMEOUT"
          ]
          ++ impureEnvVars;

        name = if name != null then name else baseNameOf gameUrl;
        # ENV
        nixpkgsVersion = lib.trivial.release;

        outputHash =
          if finalAttrs.hash == "" then
            lib.fakeHash
          else if finalHashHasColon then
            lib.elemAt finalHashColonMatch 1
          else
            finalAttrs.hash;

        outputHashAlgo = if finalHashHasColon then lib.head finalHashColonMatch else null;
        outputHashMode = "flat";
        uploadName = name;
      }
    );

  inheritFunctionArgs = false;
}
