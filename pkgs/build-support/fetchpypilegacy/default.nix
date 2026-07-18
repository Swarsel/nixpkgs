# Fetch from PyPi legacy API as documented in https://warehouse.pypa.io/api-reference/legacy.html
{
  lib,
  cacert,
  python3,
  runCommand,
}@pkgs:
let
  inherit (lib)
    optionalAttrs
    fetchers
    optional
    inPureEvalMode
    filter
    head
    concatStringsSep
    escapeShellArg
    ;

  impureEnvVars = fetchers.proxyImpureEnvVars ++ optional inPureEvalMode "NETRC";
in
lib.makeOverridable (
  {
    # filename including extension
    file,
    # SRI hash
    hash,
    # package name
    pname,
    # allow overriding cacert using src.override { cacert = cacert.override { extraCertificateFiles = [ ./path/to/cert.pem ]; }; }
    cacert ? pkgs.cacert,
    # allow overriding the derivation name
    name ? null,
    # Package index
    url ? null,
    # Multiple package indices to consider
    urls ? [ ],
  }:
  let
    urls' = urls ++ optional (url != null) url;

    pathParts = filter ({ path, prefix }: "NETRC" == prefix) builtins.nixPath;
    netrc_file = if (pathParts != [ ]) then (head pathParts).path else "";

  in
  # Assert that we have at least one URL
  assert urls' != [ ];
  runCommand file
    (
      {
        inherit impureEnvVars;

        nativeBuildInputs = [
          python3
          cacert
        ];

        outputHash = hash;
        # if hash is empty select a default algo to let nix propose the actual hash.
        outputHashAlgo = if hash == "" then "sha256" else null;
        outputHashMode = "flat";
      }
      // optionalAttrs (name != null) { inherit name; }
      // optionalAttrs (!inPureEvalMode) { env.NETRC = netrc_file; }
    )
    ''
      python ${./fetch-legacy.py} ${
        concatStringsSep " " (map (url: "--url ${escapeShellArg url}") urls')
      } --pname ${pname} --filename ${file}
      mv ${file} $out
    ''
)
