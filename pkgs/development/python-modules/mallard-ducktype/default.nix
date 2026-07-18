{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mallard-ducktype";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "projectmallard";
    repo = "mallard-ducktype";
    tag = version;
    hash = "sha256-jHjzTBBRBh//bOrdnyCRmZRmpupgDaDRuZGAd75baco=";
  };

  checkPhase = ''
    runHook preCheck
    pushd tests
    ./runtests
    popd
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "mallard" ];

  meta = {
    description = "Parser for the lightweight Ducktype syntax for Mallard";
    homepage = "https://github.com/projectmallard/mallard-ducktype";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
