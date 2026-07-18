{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "funcparserlib";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "vlasovskikh";
    repo = "funcparserlib";
    rev = version;
    hash = "sha256-LE9ItCaEzEGeahpM3M3sSnDBXEr6uX5ogEkO5x2Jgzc=";
  };

  nativeBuildInputs = [ poetry-core ];

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "funcparserlib" ];

  meta = {
    description = "Recursive descent parsing library based on functional combinators";
    homepage = "https://github.com/vlasovskikh/funcparserlib";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
