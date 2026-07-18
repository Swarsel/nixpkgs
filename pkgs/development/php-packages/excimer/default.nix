{
  lib,
  fetchFromGitHub,
  buildPecl,
}:

let
  version = "1.2.6";
in
buildPecl {
  inherit version;
  pname = "excimer";

  src = fetchFromGitHub {
    owner = "wikimedia";
    repo = "mediawiki-php-excimer";
    tag = version;
    hash = "sha256-LnmhItq7OpxXXE6EnTOXZVdfo+MTa2Ud9j16rs8dTBo=";
  };

  meta = {
    description = "PHP extension that provides an interrupting timer and a low-overhead sampling profiler";
    homepage = "https://mediawiki.org/wiki/Excimer";
    changelog = "https://pecl.php.net/package-changelog.php?package=excimer&release=${version}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.php ];
  };
}
