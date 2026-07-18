{
  lib,
  curl, # Note that `curl' may be `null', in case of the native stdenvNoCC.
  hashedMirrors,
  rewriteURL,
  stdenvNoCC,
  buildPackages ? {
    inherit stdenvNoCC;
  },
  cacert ? null,
}:

let
  defaultNativeBuildInputs = [ curl ];
  inherit (lib)
    concatMap
    elemAt
    fakeHash
    fakeSha256
    fakeSha512
    filter
    hasPrefix
    head
    isList
    isString
    length
    match
    warn
    ;
  nixpkgsVersion = lib.trivial.release;

  mirrors = import ./mirrors.nix // {
    inherit hashedMirrors;
  };

  # Write the list of mirrors to a file that we can reuse between
  # fetchurl instantiations, instead of passing the mirrors to
  # fetchurl instantiations via environment variables.  This makes the
  # resulting store derivations (.drv files) much smaller, which in
  # turn makes nix-env/nix-instantiate faster.
  mirrorsFile = buildPackages.stdenvNoCC.mkDerivation (
    {
      strictDeps = true;
      builder = ./write-mirror-list.sh;
      name = "mirrors-list";
      preferLocalBuild = true;
    }
    // mirrors
  );

  # Names of the master sites that are mirrored (i.e., "sourceforge",
  # "gnu", etc.).
  sites = builtins.attrNames mirrors;

  /**
    Resolve a URL against the available mirrors.

    If the input is a `"mirror://"` URL, it is normalized.
    Otherwise, the URL is returned unmodified in a singleton list.

    Mirror URLs should be formatted as:
    ```
    mirror://{mirror_name}/{path}
    ```

    The specified `mirror_name` must correspond to an entry in `pkgs/build-support/fetchurl/mirrors.nix`, otherwise an error is thrown.

    # Inputs

    `url` (String)
    : A (possibly `"mirror://"`) URL to resolve.

    # Output

    A list of resolved URLs.
  */
  resolveUrl =
    url:
    let
      mirrorSplit = match "mirror://([[:alpha:]]+)/(.+)" url;
      mirrorName = head mirrorSplit;
      mirrorList = mirrors."${mirrorName}" or (throw "unknown mirror:// site ${mirrorName}");
    in
    if mirrorSplit == null || mirrorName == null then
      [ url ]
    else
      map (mirror: mirror + elemAt mirrorSplit 1) mirrorList;

  rewriteAllUrls =
    urls:
    if rewriteURL == null then
      urls
    else
      let
        u = concatMap (
          url:
          let
            rewritten = rewriteURL url;
          in
          if isString rewritten then [ rewritten ] else [ ]
        ) urls;
      in
      if u == [ ] then throw "urls is empty after rewriteURL (was ${toString urls})" else u;

  impureEnvVars =
    lib.fetchers.proxyImpureEnvVars
    ++ [
      # This variable allows the user to pass additional options to curl
      "NIX_CURL_FLAGS"

      # This variable allows the user to override hashedMirrors from the
      # command-line.
      "NIX_HASHED_MIRRORS"

      # This variable allows overriding the timeout for connecting to
      # the hashed mirrors.
      "NIX_CONNECT_TIMEOUT"
    ]
    ++ (map (site: "NIX_MIRRORS_${site}") sites);

in

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    # Passed via passthru
    "url"

    # Additional stdenv.mkDerivation arguments from derived fetchers.
    "derivationArgs"

    # Hash attributes will be map to the corresponding outputHash*
    "sha1"
    "sha256"
    "sha512"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      # Additional curl options needed for the download to succeed.
      # Warning: Each space (no matter the escaping) will start a new argument.
      # If you wish to pass arguments with spaces, use `curlOptsList`
      curlOpts ? "",
      # Additional curl options needed for the download to succeed.
      curlOptsList ? [ ],
      # Additional stdenvNoCC.mkDerivation arguments.
      # It is typically for derived fetchers to pass down additional arguments,
      # and the specified arguments have lower precedence than other mkDerivation arguments.
      derivationArgs ? { },
      # Whether to download to a temporary path rather than $out. Useful
      # in conjunction with postFetch. The location of the temporary file
      # is communicated to postFetch via $downloadedFile.
      downloadToTemp ? false,
      # If true, set executable bit on downloaded file
      executable ? false,
      # SRI hash.
      hash ? "",
      # Meta information, if any.
      meta ? { },
      # Name of the file when pname + version is unspecified.
      # Default to the basename of `url' (or of the first element of `urls').
      name ? null,
      # Additional packages needed as part of a fetch
      nativeBuildInputs ? [ ],
      # Impure env vars (https://nixos.org/nix/manual/#sec-advanced-attributes)
      # needed for netrcPhase
      netrcImpureEnvVars ? [ ],
      # Shell code to build a netrc file for BASIC auth
      netrcPhase ? null,
      # Legacy ways of specifying the hash.
      outputHash ? "",
      outputHashAlgo ? "",
      # Passthru information, if any.
      passthru ? { },
      # for versioned downloads optionally take pname + version.
      pname ? null,
      # Shell code executed after the file has been fetched
      # successfully. This can do things like check or transform the file.
      postFetch ? "",
      # Doing the download on a remote machine just duplicates network
      # traffic, so don't do that by default
      preferLocalBuild ? true,
      recursiveHash ? false,
      sha1 ? "",
      sha256 ? "",
      sha512 ? "",
      # If set, don't download the file, but write a list of all possible
      # URLs (resulting from resolving mirror:// URLs) to $out.
      showURLs ? false,
      # URL to fetch.
      url ? "",
      # Alternatively, a list of URLs specifying alternative download
      # locations.  They are tried in order.
      urls ? [ ],
      version ? null,
    }@args:

    let
      preRewriteUrls =
        if urls != [ ] && url == "" then
          (if isList urls then urls else throw "`urls` is not a list: ${lib.generators.toPretty { } urls}")
        else if urls == [ ] && url != "" then
          (
            if isString url then [ url ] else throw "`url` is not a string: ${lib.generators.toPretty { } urls}"
          )
        else
          throw "fetchurl requires either `url` or `urls` to be set: ${lib.generators.toPretty { } args}";

      urls_ = rewriteAllUrls preRewriteUrls;

      hash_ =
        if
          length (
            filter (s: s != "") [
              hash
              outputHash
              sha1
              sha256
              sha512
            ]
          ) > 1
        then
          throw "multiple hashes passed to fetchurl: ${lib.generators.toPretty { } urls_}"
        else

        if hash != "" then
          {
            outputHash = hash;
            outputHashAlgo = null;
          }
        else if outputHash != "" then
          if outputHashAlgo != "" then
            { inherit outputHashAlgo outputHash; }
          else
            throw "fetchurl was passed outputHash without outputHashAlgo: ${lib.generators.toPretty { } urls_}"
        else if sha512 != "" then
          {
            outputHash = sha512;
            outputHashAlgo = "sha512";
          }
        else if sha256 != "" then
          {
            outputHash = sha256;
            outputHashAlgo = "sha256";
          }
        else if sha1 != "" then
          {
            outputHash = sha1;
            outputHashAlgo = "sha1";
          }
        else if cacert != null then
          {
            outputHash = fakeHash;
            outputHashAlgo = null;
          }
        else
          throw "fetchurl requires a hash for fixed-output derivation: ${lib.generators.toPretty { } urls_}";

      finalHashHasColon = match ".*:.*" finalAttrs.hash != null;
      finalHashColonMatch = match "([^:]+)[:](.*)" finalAttrs.hash;
    in

    derivationArgs
    // {
      inherit
        curlOptsList
        downloadToTemp
        executable
        mirrorsFile
        postFetch
        showURLs
        ;

      inherit nixpkgsVersion;
      inherit preferLocalBuild;
      inherit meta;
      nativeBuildInputs = defaultNativeBuildInputs ++ nativeBuildInputs;

      # Disable TLS verification only when we know the hash and no credentials are
      # needed to access the resource
      env.SSL_CERT_FILE =
        if
          (
            hash_.outputHash == ""
            || hash_.outputHash == fakeSha256
            || hash_.outputHash == fakeSha512
            || hash_.outputHash == fakeHash
            || netrcPhase != null
          )
        then
          "${cacert}/etc/ssl/certs/ca-bundle.crt"
        else
          "/no-cert-file.crt";

      __structuredAttrs = true;
      builder = ./builder.sh;

      curlOpts =
        if isList curlOpts then
          warn (
            let
              url = toString (builtins.head urls_);
              curlOptsRepresentation = lib.generators.toPretty { multiline = false; } curlOpts;
              curlOptsAsStringRepresentation = lib.strings.escapeNixString (toString curlOpts);
              curlOptsListElementsRepresentation =
                lib.concatMapStringsSep " " lib.strings.escapeNixString
                  curlOpts;
            in
            ''
              fetchurl for ${url}: curlOpts is a list (${curlOptsRepresentation}), which is not supported anymore.
              - If you wish to get the same effect as before, for elements with spaces (even if escaped) to expand to multiple curl arguments, use a string argument instead:
                curlOpts = ${curlOptsAsStringRepresentation};
              - If you wish for each list element to be passed as a separate curl argument, allowing arguments to contain spaces, use curlOptsList instead:
                curlOptsList = [ ${curlOptsListElementsRepresentation} ];
            ''
          ) curlOpts
        else
          curlOpts;

      # New-style output content requirements.
      hash =
        if
          hash_.outputHashAlgo == null
          || hash_.outputHash == ""
          || hasPrefix hash_.outputHashAlgo hash_.outputHash
        then
          hash_.outputHash
        else
          "${hash_.outputHashAlgo}:${hash_.outputHash}";

      impureEnvVars = impureEnvVars ++ netrcImpureEnvVars;

      name =
        if finalAttrs.pname or null != null && finalAttrs.version or null != null then
          "${finalAttrs.pname}-${finalAttrs.version}"
        else if showURLs then
          "urls"
        else if name != null then
          name
        else
          baseNameOf (toString (head urls_));

      outputHash =
        if finalAttrs.hash == "" then
          fakeHash
        else if finalHashHasColon then
          elemAt finalHashColonMatch 1
        else
          finalAttrs.hash;

      outputHashAlgo = if finalHashHasColon then head finalHashColonMatch else null;
      outputHashMode = if (recursiveHash || executable) then "recursive" else "flat";
      # If set, prefer the content-addressable mirrors
      # (http://tarballs.nixos.org) over the original URLs.
      preferHashedMirrors = false;
      urls = urls_;

      passthru = {
        inherit url;
        resolvedUrl = head (resolveUrl url);
      }
      // passthru;
    };

  # No ellipsis
  inheritFunctionArgs = false;
}
// {
  inherit resolveUrl;
}
