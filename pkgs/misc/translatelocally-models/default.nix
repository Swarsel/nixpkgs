let
  modelSpecs = (builtins.fromJSON (builtins.readFile ./models.json));
in

{
  lib,
  fetchurl,
  stdenvNoCC,
}:

let
  withCodeAsKey = f: { code, ... }@attrs: lib.nameValuePair code (f attrs);
  mkModelPackage =
    {
      checksum,
      code,
      name,
      url,
      version,
    }:
    stdenvNoCC.mkDerivation {
      pname = "translatelocally-model-${code}";
      version = toString version;

      src = fetchurl {
        inherit url;
        sha256 = checksum;
      };

      installPhase = ''
        TARGET="$out/share/translateLocally/models"
        mkdir -p "$TARGET"
        tar -xzf "$src" -C "$TARGET"

        # avoid patching shebangs in inconsistently executable extra files
        find "$out" -type f -exec chmod -x {} +
      '';

      dontUnpack = true;

      meta = {
        description = "TranslateLocally model - ${name}";
        homepage = "https://translatelocally.com/";
        # https://github.com/browsermt/students/blob/master/LICENSE.md
        license = lib.licenses.cc-by-sa-40;
      };
    };
  allModelPkgs = lib.listToAttrs (map (withCodeAsKey mkModelPackage) modelSpecs);

in
allModelPkgs
// {
  passthru.updateScript = ./update.sh;
}
