{
  lib,
  awscli2,
  runCommand,
}:
lib.fetchers.withNormalizedHash { } (
  {
    outputHash,
    outputHashAlgo,
    s3url,
    credentials ? null, # Default to looking at local EC2 metadata service
    name ? baseNameOf s3url,
    postFetch ? null,
    recursiveHash ? false,
    region ? "us-east-1",
  }:

  let
    mkCredentials =
      {
        access_key_id,
        secret_access_key,
        session_token ? null,
      }:
      {
        AWS_ACCESS_KEY_ID = access_key_id;
        AWS_SECRET_ACCESS_KEY = secret_access_key;
        AWS_SESSION_TOKEN = session_token;
      };

    credentialAttrs = lib.optionalAttrs (credentials != null) (mkCredentials credentials);
  in
  runCommand name
    (
      {
        inherit outputHash outputHashAlgo;
        nativeBuildInputs = [ awscli2 ];
        AWS_DEFAULT_REGION = region;
        outputHashMode = if recursiveHash then "recursive" else "flat";
        preferLocalBuild = true;
      }
      // credentialAttrs
    )
    (
      if postFetch != null then
        ''
          downloadedFile="$(mktemp)"
          aws s3 cp ${s3url} $downloadedFile
          ${postFetch}
        ''
      else
        ''
          aws s3 cp ${s3url} $out
        ''
    )
)
