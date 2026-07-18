{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinx-autodoc-typehints";
  version = "3.10.5";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "sphinx-autodoc-typehints";
    tag = finalAttrs.version;
    hash = "sha256-ClRfCv3UvUdnSnm5XuyrWj8oFQMSAPb3ZCDokAWI4cE=";
  };

  # requires spobjinv, nbtyping
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinx_autodoc_typehints" ];

  meta = {
    description = "Type hints (PEP 484) support for the Sphinx autodoc extension";
    homepage = "https://github.com/tox-dev/sphinx-autodoc-typehints";
    changelog = "https://github.com/tox-dev/sphinx-autodoc-typehints/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
