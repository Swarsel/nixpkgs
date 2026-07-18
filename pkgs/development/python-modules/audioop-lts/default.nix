{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "audioop-lts";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "AbstractUmbra";
    repo = "audioop";
    tag = version;
    hash = "sha256-C1z24kH5t0RSVqjT8SBdrilMtVs7pTI1vd+iwMk3RXE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    rm -rf audioop
  '';

  build-system = [ setuptools ];
  disabled = pythonOlder "3.13";
  pyproject = true;

  pythonImportsCheck = [
    "audioop"
  ];

  meta = {
    description = "LTS port of Python's `audioop` module";
    homepage = "https://github.com/AbstractUmbra/audioop";
    changelog = "https://github.com/AbstractUmbra/audioop/releases/tag/${version}";
    license = lib.licenses.psfl;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
