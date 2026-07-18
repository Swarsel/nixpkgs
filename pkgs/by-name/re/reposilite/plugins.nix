{
  lib,
  generateSplicesForMkScope,
  makeScopeWithSplicing',
}:
let
  pluginHashes = lib.importJSON ./plugins.json;
in
makeScopeWithSplicing' {
  f =
    self:
    {
      fetchPlugin = self.callPackage (
        {
          lib,
          fetchurl,
          reposilite,
        }:
        lib.makeOverridable (
          {
            hash,
            name,
          }:
          let
            inherit (reposilite) version;
            pname = name;

            fancyName = lib.concatStrings [
              (lib.toUpper (builtins.substring 0 1 name))
              (builtins.substring 1 ((builtins.stringLength name) - 1) name)
            ];
          in
          fetchurl {
            inherit pname version hash;
            url = "https://maven.reposilite.com/releases/com/reposilite/plugin/${name}-plugin/${version}/${name}-plugin-${version}-all.jar";

            meta = {
              inherit (reposilite.meta) platforms;
              description = "${fancyName} plugin for Reposilite.";
              homepage = "https://github.com/dzikoysk/reposilite";
              license = lib.licenses.asl20;
              sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
              maintainers = with lib.maintainers; [ uku3lig ];
            };
          }
        )
      ) { };
    }
    // builtins.mapAttrs (name: hash: self.fetchPlugin { inherit name hash; }) pluginHashes;

  otherSplices = generateSplicesForMkScope "reposilitePlugins";
}
