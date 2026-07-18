{
  lib,
  runCommandLocal,
  xrootd,
}:

{
  hash ? lib.fakeHash,
  name ? "",
  pname ? "",
  url ? if urls == [ ] then abort "Expect either non-empty `urls` or `url`" else builtins.head urls,
  urls ? [ ],
  version ? "",
}:

(runCommandLocal name
  {
    inherit url;
    nativeBuildInputs = [ xrootd ];
    outputHash = hash;
    outputHashAlgo = null;
    outputHashMode = "flat";
    urls = if urls == [ ] then lib.singleton url else urls;
  }
  ''
    for u in $urls; do
      xrdcp --verbose --force "$u" "$out"
      ret=$?
      (( ret != 0 )) || break
    done
    if (( ret )); then
      echo "xrdcp failed trying to download any of the urls" >&2
      exit $ret
    fi
  ''
).overrideAttrs
  (
    finalAttrs:
    if (pname != "" && version != "") then
      {
        inherit pname version;
        name = "${pname}-${version}";
      }
    else
      {
        name = if (name != "") then name else (baseNameOf finalAttrs.url);
      }
  )
