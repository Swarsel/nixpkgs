{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "inwx-domrobot";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "inwx";
    repo = "python-client";
    tag = "v${version}";
    hash = "sha256-Nbs3xroJD61NbpaiTdjA3VFxzXIlnqmB1d7SJDj8VN8=";
  };

  # No tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "INWX" ];

  meta = {
    description = "INWX Domrobot Python Client";
    homepage = "https://github.com/inwx/python-client";
    changelog = "https://github.com/inwx/python-client/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadejkastelic ];
  };
}
