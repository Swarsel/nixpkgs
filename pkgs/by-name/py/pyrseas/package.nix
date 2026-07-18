{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

let
  pgdbconn = python3Packages.buildPythonPackage rec {
    pname = "pgdbconn";
    version = "0.8.0";

    src = fetchFromGitHub {
      owner = "perseas";
      repo = "pgdbconn";
      tag = "v${version}";
      sha256 = "09r4idk5kmqi3yig7ip61r6js8blnmac5n4q32cdcbp1rcwzdn6z";
    };

    # The tests are impure (they try to access a PostgreSQL server)
    doCheck = false;
    build-system = with python3Packages; [ setuptools ];

    dependencies = with python3Packages; [
      psycopg2
    ];

    pyproject = true;
  };
in

python3Packages.buildPythonApplication rec {
  pname = "pyrseas";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "perseas";
    repo = "Pyrseas";
    tag = "v${version}";
    sha256 = "sha256-+MxnxvbLMxK1Ak+qKpKe3GHbzzC+XHO0eR7rl4ON9H4=";
  };

  # The tests are impure (they try to access a PostgreSQL server)
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    psycopg2
    pyyaml
    pgdbconn
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyrseas" ];

  meta = {
    description = "Declarative language to describe PostgreSQL databases";
    homepage = "https://perseas.github.io/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pmeunier ];
  };
}
