{
  lib,
  fetchFromGitHub,
  JSONXS,
  PodMarkdown,
  TextCSV_XS,
  buildPerlPackage,
  bzip2,
  nix-update-script,
  pgbadger,
  testers,
  which,
}:

buildPerlPackage rec {
  pname = "pgbadger";
  version = "13.2";

  src = fetchFromGitHub {
    owner = "darold";
    repo = "pgbadger";
    tag = "v${version}";
    hash = "sha256-i2EamGk+urwTQNaiphJw0QIjLq/OpRdQzsR6ytaZc7k=";
  };

  outputs = [ "out" ];

  postPatch = ''
    patchShebangs ./pgbadger
  '';

  buildInputs = [
    JSONXS
    PodMarkdown
    TextCSV_XS
  ];

  env.PERL_MM_OPT = "INSTALL_BASE=${placeholder "out"}";

  nativeCheckInputs = [
    bzip2
    which
  ];

  passthru = {
    tests.version = testers.testVersion {
      inherit version;
      command = "${lib.getExe pgbadger} --version";
      package = pgbadger;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Fast PostgreSQL Log Analyzer";
    homepage = "https://github.com/darold/pgbadger";
    changelog = "https://github.com/darold/pgbadger/raw/v${version}/ChangeLog";
    license = lib.licenses.postgresql;
    mainProgram = "pgbadger";
  };
}
