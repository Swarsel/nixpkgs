{
  lib,
  buildPythonPackage,
  fetchPypi,
  nix-update-script,
  setuptools,
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "muon-optimizer";
  version = "0.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ZcUEQfKbckjlhjg9NxJi65BiZT6CCxEUPIGnoQukjac=";
    pname = "muon_optimizer";
  };

  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    torch
  ];

  pyproject = true;

  pythonImportsCheck = [
    "muon"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Optimizer for the hidden layers of neural networks";
    homepage = "https://pypi.org/project/muon-optimizer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jlesquembre ];
  };
})
