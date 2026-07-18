{
  lib,
  fetchFromGitHub,
  # Dependencies
  biothings-client,
  buildPythonPackage,
  pandas,
  pytestCheckHook,
  requests,
  setuptools,
}:
buildPythonPackage rec {
  pname = "mygene";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "biothings";
    repo = "mygene.py";
    rev = "v${version}";
    hash = "sha256-/KxlzOTbZTN5BA0PrJyivVFh4cLtW90/EFwczda61Tg=";
  };

  build-system = [ setuptools ];

  dependencies = [
    biothings-client
    requests
  ];

  optional-dependencies = {
    complete = [ pandas ];
  };

  pyproject = true;
  pythonImportsCheck = [ "mygene" ];

  meta = {
    description = "REST web services to query/retrieve gene annotation data";
    homepage = "https://github.com/biothings/mygene.py";
    changelog = "https://github.com/biothings/mygene.py/blob/v${version}/CHANGES.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ rayhem ];
  };
}
