{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  sphinx,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "sphinx-multiversion";
  version = "0.2.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-XNHKnste7WPLjWzl6cQ4yhOvT6mOfrbzdr5UHdSZC8s=";
    pname = "sphinx-multiversion";
  };

  build-system = [ setuptools ];
  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinx_multiversion" ];

  meta = {
    description = "Sphinx extension for building self-hosted versioned docs";
    homepage = "https://sphinx-contrib.github.io/multiversion";
    changelog = "https://github.com/sphinx-contrib/multiversion/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ cynerd ];
  };
}
