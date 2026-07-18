{
  lib,
  fetchFromGitHub,
  buildPecl,
  php,
}:

let
  version = "6.3.0";
in
buildPecl {
  inherit version;
  pname = "redis";

  src = fetchFromGitHub {
    owner = "phpredis";
    repo = "phpredis";
    rev = version;
    hash = "sha256-mdphyUG4OUc1PBEA5Ub1X9afFDMJ5+HoXH4WnmeAKpE=";
  };

  internalDeps = with php.extensions; [ session ];

  meta = {
    description = "PHP extension for interfacing with Redis";
    homepage = "https://github.com/phpredis/phpredis/";
    changelog = "https://github.com/phpredis/phpredis/releases/tag/${version}";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
