{
  lib,
  fetchFromGitHub,
  perlPackages,
}:

perlPackages.buildPerlPackage rec {
  pname = "pgtop";
  version = "0.11";

  src = fetchFromGitHub {
    owner = "cosimo";
    repo = "pgtop";
    rev = "v${version}";
    sha256 = "1awyl6ddfihm7dfr5y2z15r1si5cyipnlyyj3m1l19pk98s4x66l";
  };

  outputs = [ "out" ];

  buildInputs = with perlPackages; [
    DBI
    DBDPg
    TermReadKey
    JSON
    LWP
  ];

  meta = {
    description = "PostgreSQL clone of `mytop', which in turn is a `top' clone for MySQL";
    homepage = "https://github.com/cosimo/pgtop";
    changelog = "https://github.com/cosimo/pgtop/releases/tag/v${version}";
    license = [ lib.licenses.gpl2Only ];
    maintainers = [ lib.maintainers.hagl ];
    mainProgram = "pgtop";
  };
}
