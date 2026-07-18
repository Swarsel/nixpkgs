{
  lib,
  fetchFromGitHub,
  mariadb-connector-c,
  pkgs,
  ...
}:

{
  pname = "gerbil-mysql";
  version = "unstable-2023-09-23";
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildInputs = [ mariadb-connector-c ];
  gerbil-package = "clan";
  gerbilInputs = [ ];
  git-version = "ecec94c";

  pre-src = {
    fun = fetchFromGitHub;
    owner = "mighty-gerbils";
    repo = "gerbil-mysql";
    rev = "ecec94c76d7aa23331b7e02ac7732a7923f100a5";
    sha256 = "01506r0ivgp6cxvwracmg7pwr735ngb7899ga3lxy181lzkp6b2c";
  };

  softwareName = "Gerbil-MySQL";
  version-path = "";

  meta = {
    description = "MySQL bindings for Gerbil";
    homepage = "https://github.com/mighty-gerbils/gerbil-mysql";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fare ];
    platforms = lib.platforms.unix;
  };
  # "-L${mariadb-connector-c}/lib/mariadb"
}
