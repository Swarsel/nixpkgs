{
  lib,
  fetchFromGitHub,
  aioquic,
  asyncssh,
  buildPythonPackage,
  pycryptodome,
  python-daemon,
  setuptools,
  uvloop,
}:

buildPythonPackage rec {
  pname = "pproxy";
  version = "2.7.9";

  src = fetchFromGitHub {
    owner = "qwj";
    repo = "python-proxy";
    tag = version;
    hash = "sha256-DWxbU2LtXzec1T175cMVJuWuhnxWYhe0FH67stMyOTM=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = lib.concatAttrValues optional-dependencies;

  # test suite doesn't use test runner. so need to run ``python ./tests/*``
  checkPhase = ''
    shopt -s extglob
    for f in ./tests/!(${builtins.concatStringsSep "|" disabledTests}).py ; do
      echo "***Testing $f***"
      eval "python $f"
    done
  '';

  disabledTests = [
    # Tests try to connect to outside Internet, so disabled
    "api_server"
    "api_client"
  ];

  optional-dependencies = {
    accelerated = [
      pycryptodome
      uvloop
    ];

    daemon = [ python-daemon ];
    quic = [ aioquic ];
    sshtunnel = [ asyncssh ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pproxy" ];

  meta = {
    description = "Proxy server that can tunnel among remote servers by regex rules";
    homepage = "https://github.com/qwj/python-proxy";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.ryand56 ];
    mainProgram = "pproxy";
  };
}
