{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # dependencies
  orjson,
  psutil,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "leanclient";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "oOo0oOo";
    repo = "leanclient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h90AMErcwdmHfIBgFerFEaUwjfRkJMl1iesXjtEpdlA=";
  };

  # Tests require a real Lean toolchain
  doCheck = false;
  build-system = [ hatchling ];

  dependencies = [
    orjson
    psutil
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "leanclient" ];

  meta = {
    description = "Python client for the Lean theorem prover LSP";
    homepage = "https://github.com/oOo0oOo/leanclient";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ remix7531 ];
  };
})
