{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "toolz";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-J6XHcNBowRDZ7ZMj8k8VQ+g7LzAKaHt4kcGm1Wtpe1s=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning >=2.0",' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "List processing tools and functional utilities";
    homepage = "https://github.com/pytoolz/toolz";
    changelog = "https://github.com/pytoolz/toolz/releases/tag/${version}";
    license = lib.licenses.bsd3;
  };
}
