{
  lib,
  fetchFromGitHub,
  buildPecl,
  pcre2,
  php,
  pkg-config,
}:

buildPecl rec {
  pname = "phalcon";
  version = "5.10.0";

  src = fetchFromGitHub {
    owner = "phalcon";
    repo = "cphalcon";
    rev = "v${version}";
    hash = "sha256-2dk/AjOWG2oJ3BoBODO9H4S32Jc/Z+W3qxvMkfR5oKE=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcre2 ];
  # Fix GCC 14 build.
  # from incompatible pointer type [-Wincompatible-pointer-types]
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  internalDeps = [
    php.extensions.session
    php.extensions.pdo
  ];

  sourceRoot = "${src.name}/build/phalcon";

  meta = {
    description = "Phalcon is a full stack PHP framework offering low resource consumption and high performance";
    homepage = "https://phalcon.io";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.krzaczek ];
    broken = lib.versionAtLeast php.version "8.5";
    teams = [ lib.teams.php ];
  };
}
