{
  lib,
  fetchFromGitHub,
  buildPecl,
  libcouchbase,
  php,
  replaceVars,
  zlib,
}:
let
  pname = "couchbase";
  version = "3.2.2";
in
buildPecl {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "couchbase";
    repo = "php-couchbase";
    rev = "v${version}";
    sha256 = "sha256-JpzLR4NcyShl2VTivj+15iAsTTsZmdMIdZYc3dLCbIA=";
  };

  patches = [
    (replaceVars ./libcouchbase.patch {
      inherit libcouchbase;
    })
  ];

  buildInputs = [
    libcouchbase
    zlib
  ];

  configureFlags = [ "--with-couchbase" ];

  meta = {
    description = "Couchbase Server PHP extension";
    homepage = "https://docs.couchbase.com/php-sdk/current/project-docs/sdk-release-notes.html";
    changelog = "https://github.com/couchbase/php-couchbase/releases/tag/v${version}";
    license = lib.licenses.asl20;
    broken = lib.versionAtLeast php.version "8.3";
    teams = [ lib.teams.php ];
  };
}
