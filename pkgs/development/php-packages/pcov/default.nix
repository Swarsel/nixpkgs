{
  lib,
  fetchFromGitHub,
  buildPecl,
  fetchpatch,
  pcre2,
}:

let
  version = "1.0.12";
in
buildPecl {
  inherit version;
  pname = "pcov";

  src = fetchFromGitHub {
    owner = "krakjoe";
    repo = "pcov";
    tag = "v${version}";
    hash = "sha256-yz+c1FrjGJAUgnu+azvebqoAN3I/GXLeAlKobNdDiHI=";
  };

  buildInputs = [ pcre2 ];

  meta = {
    description = "Self contained php-code-coverage compatible driver for PHP";
    homepage = "https://github.com/krakjoe/pcov";
    changelog = "https://github.com/krakjoe/pcov/releases/tag/v${version}";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
