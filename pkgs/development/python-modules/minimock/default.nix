{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "minimock";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "lowks";
    repo = "minimock";
    rev = "v${version}";
    hash = "sha256-Ut3iKc7Sr28uGgWCV3K3CS+gBta2icvbUPMjjo4fflU=";
  };

  nativeBuildInputs = [ setuptools ];
  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "minimock" ];

  meta = {
    description = "Minimalistic mocking library";
    homepage = "https://pypi.org/project/MiniMock/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
