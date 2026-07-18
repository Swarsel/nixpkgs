{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mintotp";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-0PTbXts4p0gRIBdqUm6MKVObnoBYHdLcwYEVV9d8+tU=";
  };

  build-system = [ python3Packages.setuptools ];
  pyproject = true;

  meta = {
    description = "Minimal TOTP generator";
    homepage = "https://github.com/susam/mintotp";
    changelog = "https://github.com/susam/mintotp/raw/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ provokateurin ];
    mainProgram = "mintotp";
  };
})
