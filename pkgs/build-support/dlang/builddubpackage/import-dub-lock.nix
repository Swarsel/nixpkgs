{
  lib,
  fetchurl,
  dub,
  fetchgit,
  linkFarm,
  runCommand,
}:

{
  lock,
  pname,
  version,
}:

let
  makeDubDep =
    {
      pname,
      sha256,
      version,
    }:
    {
      inherit pname version;

      src = fetchurl {
        inherit sha256;
        url = "mirror://dub/${pname}/${version}.zip";
        name = "dub-${pname}-${version}.zip";
      };
    };

  makeGitDep =
    {
      pname,
      repository,
      sha256,
      version,
    }:
    {
      inherit pname version;

      src = fetchgit {
        inherit sha256;
        url = repository;
        rev = version;
      };
    };

  lockJson = if lib.isPath lock then lib.importJSON lock else lock;
  depsRaw = lib.mapAttrsToList (pname: args: { inherit pname; } // args) lockJson.dependencies;

  dubDeps = map makeDubDep (lib.filter (args: !(args ? repository)) depsRaw);
  gitDeps = map makeGitDep (lib.filter (args: args ? repository) depsRaw);

  # a directory with multiple single element registries
  # one big directory with all .zip files leads to version parsing errors
  # when the name of a package is a prefix of the name of another package
  dubRegistryBase = linkFarm "dub-registry-base" (
    map (dep: {
      name = "${dep.pname}/${dep.pname}-${dep.version}.zip";
      path = dep.src;
    }) dubDeps
  );

in
runCommand "${pname}-${version}-dub-deps"
  {
    nativeBuildInputs = [ dub ];
  }
  ''
    export DUB_HOME="$out/.dub"
    mkdir -p "$DUB_HOME"
    # register dub dependencies
    ${lib.concatMapStringsSep "\n" (dep: ''
      dub fetch ${dep.pname}@${dep.version} --cache=user --skip-registry=standard --registry=file://${dubRegistryBase}/${dep.pname}
    '') dubDeps}
    # register git dependencies
    ${lib.concatMapStringsSep "\n" (dep: ''
      mkdir -p "$DUB_HOME/packages/${dep.pname}/${dep.version}"
      cp -r --no-preserve=all ${dep.src} "$DUB_HOME/packages/${dep.pname}/${dep.version}/${dep.pname}"
    '') gitDeps}
  ''
