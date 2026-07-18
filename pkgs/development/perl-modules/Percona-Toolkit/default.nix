{
  lib,
  fetchFromGitHub,
  DBDmysql,
  DBI,
  IOSocketSSL,
  TermReadKey,
  buildGoModule,
  buildPerlPackage,
  git,
  go,
}:

let
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "percona";
    repo = "percona-toolkit";
    rev = "v${version}";
    sha256 = "sha256-NpLUHIdGnuNJmSYBYErU7yzFkxKRFQVWJHJqJ2q4U5E=";
    # needed for build script
    leaveDotGit = true;
  };

  goDeps =
    (buildGoModule {
      inherit src version;
      pname = "Percona-Toolkit go-bindings";
      vendorHash = "sha256-HAaoVYK6av085zSG0ZRpbmUgEA2UEt7CGWF/834e+z4=";
    }).goModules;
in
buildPerlPackage {
  inherit src version;
  pname = "Percona-Toolkit";
  outputs = [ "out" ];

  postPatch = ''
    cp -r --reflink=auto ${goDeps} vendor
    chmod -R u+rw vendor
    substituteInPlace src/go/Makefile \
      --replace-fail "go get ./..." "echo 'Skipping go get due to offline build'"
  '';

  nativeBuildInputs = [
    git
  ];

  buildInputs = [
    DBDmysql
    go
    DBI
    IOSocketSSL
    TermReadKey
  ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  meta = {
    description = "Collection of advanced command-line tools to perform a variety of MySQL and system tasks";
    homepage = "https://www.percona.com/software/database-tools/percona-toolkit";
    changelog = "https://docs.percona.com/percona-toolkit/release_notes.html";
    license = with lib.licenses; [ gpl2Only ];
    maintainers = with lib.maintainers; [ izorkin ];
  };
}
