{
  lib,
  fetchurl,
  buildNpmPackage,
  hash,
  npmDepsHash,
  packageLockFile,
  version,
}:

buildNpmPackage rec {
  inherit version;
  inherit npmDepsHash;
  pname = "lerna";

  src = fetchurl {
    inherit hash;
    url = "https://registry.npmjs.org/lerna/-/lerna-${version}.tgz";
  };

  postPatch = ''
    ln -s ${packageLockFile} package-lock.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "Fast, modern build system for managing and publishing multiple JavaScript/TypeScript packages from the same repository";
    homepage = "https://lerna.js.org/";
    changelog = "https://github.com/lerna/lerna/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ThaoTranLePhuong ];
  };
}
