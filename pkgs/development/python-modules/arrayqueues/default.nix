{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "arrayqueues";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "portugueslab";
    repo = "arrayqueues";
    tag = "v${version}";
    hash = "sha256-tqIfpkwbJNd9jMe0YvAWz9Z8rOO80qxVM2ZcJFeAmwo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "arrayqueues" ];

  meta = {
    description = "Multiprocessing queues for numpy arrays using shared memory";
    homepage = "https://github.com/portugueslab/arrayqueues";
    changelog = "https://github.com/portugueslab/arrayqueues/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
