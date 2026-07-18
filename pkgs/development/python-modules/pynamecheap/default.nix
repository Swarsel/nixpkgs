{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pynamecheap";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "Bemmu";
    repo = "PyNamecheap";
    tag = "v${version}";
    hash = "sha256-J2WYWtZGtZiox4q9tdkLyU1nix9Jn64K0+1mw7xoLLw=";
  };

  # Tests require access to api.sandbox.namecheap.com
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "namecheap" ];

  meta = {
    description = "Namecheap API client in Python";
    homepage = "https://github.com/Bemmu/PyNamecheap";
    changelog = "https://github.com/Bemmu/PyNamecheap/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
