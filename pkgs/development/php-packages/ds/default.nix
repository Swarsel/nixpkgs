{
  lib,
  fetchFromGitHub,
  buildPecl,
  pcre2,
  php,
}:

let
  version = "2.0.0";
in
buildPecl {
  inherit version;
  pname = "ds";

  src = fetchFromGitHub {
    owner = "php-ds";
    repo = "ext-ds";
    rev = "v${version}";
    sha256 = "sha256-QWBxjt3rzD3m3y2ScbYvtZnjPUYsd3uMMQOFY/RQ3Io=";
  };

  buildInputs = [ pcre2 ];

  meta = {
    description = "Extension providing efficient data structures for PHP";
    homepage = "https://github.com/php-ds/ext-ds";
    changelog = "https://github.com/php-ds/ext-ds/releases/tag/v${version}";
    license = lib.licenses.mit;
    teams = [ lib.teams.php ];
  };
}
