{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dowhen";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "gaogaotiantian";
    repo = "dowhen";
    tag = version;
    hash = "sha256-7eoNe9SvE39J4mwIOxvbU1oh/L7tr/QM1uuBDqWtQu0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "dowhen" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Intuitive and low-overhead instrumentation tool for Python";
    homepage = "https://github.com/gaogaotiantian/dowhen";
    changelog = "https://github.com/gaogaotiantian/dowhen/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
