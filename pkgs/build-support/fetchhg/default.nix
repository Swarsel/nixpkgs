{
  lib,
  mercurial,
  stdenvNoCC,
}:

lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  extendDrvArgs =
    finalAttrs:
    {
      url,
      fetchSubrepos ? false,
      hash ? null,
      name ? null,
      preferLocalBuild ? true,
      rev ? null,
      sha256 ? null,
    }:
    # TODO: statically check if mercurial has https support if the url starts with https.
    {
      inherit url rev hash;
      inherit preferLocalBuild;
      nativeBuildInputs = [ mercurial ];
      builder = ./builder.sh;
      impureEnvVars = lib.fetchers.proxyImpureEnvVars;
      name = "hg-archive" + (lib.optionalString (name != null) "-${name}");

      outputHash =
        if (hash != null && sha256 != null) then
          throw "Only one of sha256 or hash can be set"
        else
          (
            if finalAttrs.hash != null then
              finalAttrs.hash
            else if sha256 != null then
              sha256
            else
              ""
          );

      outputHashAlgo = if finalAttrs.hash != null && finalAttrs.hash != "" then null else "sha256";
      outputHashMode = "recursive";
      subrepoClause = lib.optionalString fetchSubrepos "S";
    };

  # No ellipsis
  inheritFunctionArgs = false;
}
