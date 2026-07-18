{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "pfzy";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "kazhala";
    repo = "pfzy";
    tag = version;
    hash = "sha256-+Ba/yLUfT0SPPAJd+pKyjSvNrVpEwxW3xEKFx4JzpYk=";
  };

  nativeBuildInputs = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "pfzy" ];

  meta = {
    description = "Python port of the fzy fuzzy string matching algorithm";
    homepage = "https://github.com/kazhala/pfzy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
