{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # pythonPackages
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyhcl";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "virtuald";
    repo = "pyhcl";
    tag = version;
    hash = "sha256-djT0ao1WbM/sLKRycdA5J4IRu8NbmDayVKBdE4s6E2M=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  # https://github.com/virtuald/pyhcl/blob/51a7524b68fe21e175e157b8af931016d7a357ad/setup.py#L64
  configurePhase = ''
    echo '__version__ = "${version}"' > ./src/hcl/version.py
  '';

  pyproject = true;

  meta = {
    description = "HCL is a configuration language. pyhcl is a python parser for it";
    homepage = "https://github.com/virtuald/pyhcl";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ kamadorueda ];
    mainProgram = "hcltool";
  };
}
