{
  lib,
  fetchFromGitHub,
  buildPecl,
  judy,
}:

let
  version = "3.1.0";
in
buildPecl {
  inherit version;
  pname = "memprof";

  src = fetchFromGitHub {
    owner = "arnaud-lb";
    repo = "php-memory-profiler";
    rev = version;
    hash = "sha256-gq+txAU2Fw+Zm1aIu0lwPUHRqtccNcHFpp0fm3f7BnQ=";
  };

  buildInputs = [
    judy
  ];

  configureFlags = [
    "--with-judy-dir=${lib.getDev judy}"
  ];

  doCheck = true;

  meta = {
    description = "Memory profiler for PHP. Helps finding memory leaks in PHP scripts";
    homepage = "https://github.com/arnaud-lb/php-memory-profiler";
    changelog = "https://github.com/arnaud-lb/php-memory-profiler/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
