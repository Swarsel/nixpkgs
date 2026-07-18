{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pandas,
  poetry-core,
  pydantic,
  requests,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "cmsdials";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "cms-DQM";
    repo = "dials-py";
    tag = "v${version}";
    hash = "sha256-bYFADE6Fi0hQ0IaaeN3RhtPPQwWqhhRbNyGOUPLksp4=";
  };

  build-system = [ poetry-core ];

  dependencies = [
    pydantic
    requests
    typing-extensions
  ];

  optional-dependencies = {
    pandas = [ pandas ];
    tqdm = [ tqdm ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cmsdials" ];

  pythonRelaxDeps = [
    # pydantic = "<2, >=1"pydantic = "<2, >=1"
    "pydantic"
    # typing-extensions = "<4.6.0, >=3.6.6"
    "typing-extensions"
  ];

  meta = {
    description = "Python API client interface to CMS DIALS service";
    homepage = "https://github.com/cms-DQM/dials-py";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ShamrockLee ];
  };
}
