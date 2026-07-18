{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lazy-loader";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "scientific-python";
    repo = "lazy_loader";
    tag = "v${version}";
    hash = "sha256-4Kid6yhm9C2liPoW+NlCsOiBZvv6iYt7hDunARc4PRY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lazy_loader" ];

  meta = {
    description = "Populate library namespace without incurring immediate import costs";
    homepage = "https://github.com/scientific-python/lazy_loader";
    changelog = "https://github.com/scientific-python/lazy_loader/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
