{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  inflect,
  more-itertools,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "jaraco-itertools";
  version = "6.4.3";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "jaraco.itertools";
    tag = "v${version}";
    hash = "sha256-LjWkyY9I8BBYpFm8TT3kq4vk63pNQrnZ15haJCQ5xlk=";
  };

  postPatch = ''
    # downloads license texts at build time
    sed -i "/coherent\.licensed/d" pyproject.toml
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];

  dependencies = [
    inflect
    more-itertools
  ];

  pyproject = true;
  pythonImportsCheck = [ "jaraco.itertools" ];
  pythonNamespaces = [ "jaraco" ];

  meta = {
    description = "Tools for working with iterables";
    homepage = "https://github.com/jaraco/jaraco.itertools";
    license = lib.licenses.mit;
  };
}
