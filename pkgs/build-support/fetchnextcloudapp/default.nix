{
  lib,
  fetchurl,
  applyPatches,
  fetchzip,
  ...
}:
{
  license,
  url,
  appName ? null,
  appVersion ? null,
  description ? null,
  hash ? "",
  homepage ? null,
  longDescription ? description,
  maintainers ? [ ],
  name ?
    if appName == null || appVersion == null then null else "nextcloud-app-${appName}-${appVersion}",
  patches ? [ ],
  sha256 ? "",
  sha512 ? "",
  teams ? [ ],
  unpack ? false, # whether to use fetchzip rather than fetchurl
}:
applyPatches {
  inherit patches;

  src = (if unpack then fetchzip else fetchurl) {
    inherit url;
    ${if hash == "" then null else "hash"} = hash;
    ${if sha256 == "" then null else "sha256"} = sha256;
    ${if sha512 == "" then null else "sha512"} = sha512;

    meta = {
      inherit maintainers teams;
      license = lib.licenses.${license};

      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryBytecode # vendored deps, compiled vue templates, etc
      ];

      ${if description == null then null else "description"} = description;
      ${if homepage == null then null else "homepage"} = homepage;
      ${if longDescription == null then null else "longDescription"} = longDescription;
    };
  };

  ${if name == null then null else "name"} = name;

  prePatch = ''
    if [ ! -f ./appinfo/info.xml ]; then
      echo "appinfo/info.xml doesn't exist in $out, aborting!"
      exit 1
    fi
  '';
}
