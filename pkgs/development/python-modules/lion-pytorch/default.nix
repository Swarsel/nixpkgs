{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  torch,
}:

buildPythonPackage rec {
  pname = "lion-pytorch";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "lucidrains";
    repo = "lion-pytorch";
    tag = version;
    hash = "sha256-RHixPIZ1kCawWQiqYqLY+c3r6Rg86LKm3tQTyW2BNFU=";
  };

  propagatedBuildInputs = [ torch ];
  doCheck = false; # no tests currently
  format = "setuptools";
  pythonImportsCheck = [ "lion_pytorch" ];

  meta = {
    description = "Optimizer tuned by Google Brain using genetic algorithms";
    homepage = "https://github.com/lucidrains/lion-pytorch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
