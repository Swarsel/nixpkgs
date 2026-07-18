{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinx-thebe";
  version = "0.3.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-V2BH9FVg6C9kql8VIAsesJTc/hxbj1MaimW9II4lpJM=";
    pname = "sphinx_thebe";
  };

  nativeBuildInputs = [
    hatch-vcs
    hatchling
  ];

  propagatedBuildInputs = [ sphinx ];
  pyproject = true;
  pythonImportsCheck = [ "sphinx_thebe" ];

  meta = {
    description = "Integrate interactive code blocks into your documentation with Thebe and Binder";
    homepage = "https://github.com/executablebooks/sphinx-thebe";
    changelog = "https://github.com/executablebooks/sphinx-thebe/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
