{
  lib,
  gfal2-util,
  runCommandLocal,
}:

# `url` and `urls` should only be overridden via `<pkg>.override`, but not `<pkg>.overrideAttrs`.
{
  allowSubstitutes ? true,
  extraGfalCopyFlags ? [ ],
  hash ? lib.fakeHash,
  intermediateDestUrls ? [ ],
  name ? "",
  pname ? "",
  recursive ? false,
  url ? if urls == [ ] then abort "Expect either non-empty `urls` or `url`" else lib.head urls,
  urls ? [ ],
  version ? "",
}:

(runCommandLocal name { } ''
  for u in "''${urls[@]}"; do
    gfal-copy "''${gfalCopyFlags[@]}" "$u" "''${intermediateDestUrls[@]}" "$out"
    ret="$?"
    (( ret )) && break
  done
  if (( ret )); then
    echo "gfal-copy failed trying to download from any of the urls" >&2
    exit "$ret"
  fi
'').overrideAttrs
  (
    finalAttrs: previousAttrs:
    {
      inherit allowSubstitutes;
      inherit url;
      inherit recursive intermediateDestUrls;
      nativeBuildInputs = [ gfal2-util ];
      __structuredAttrs = true;
      gfalCopyFlags = extraGfalCopyFlags ++ lib.optional finalAttrs.recursive "--recursive";
      outputHash = hash;
      outputHashAlgo = null;
      outputHashMode = if finalAttrs.recursive then "recursive" else "flat";
      urls = if urls == [ ] then lib.singleton url else urls;
    }
    // (
      if (pname != "" && version != "") then
        {
          inherit pname version;
          name = "${finalAttrs.pname}-${finalAttrs.version}";
        }
      else
        { name = if (name != "") then name else (baseNameOf url); }
    )
  )
