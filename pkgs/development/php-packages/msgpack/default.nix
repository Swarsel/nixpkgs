{ lib, buildPecl }:

buildPecl rec {
  pname = "msgpack";
  version = "3.0.0";
  sha256 = "sha256-VTBqhHl9OZxrJpGB7EhGNPGL6hMwu9nXQFBDxZfeac0=";

  meta = {
    description = "PHP extension for interfacing with MessagePack";
    homepage = "https://github.com/msgpack/msgpack-php";
    changelog = "https://pecl.php.net/package-info.php?package=msgpack&version=${version}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.ostrolucky ];
    teams = [ lib.teams.php ];
  };
}
