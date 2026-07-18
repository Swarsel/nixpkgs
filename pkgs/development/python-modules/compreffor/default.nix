{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  fonttools,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "compreffor";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-fqA0pQxZzHhzLxSABA6sK7Nvgmzi62B8MCm104qxG6g=";
  };

  postPatch = ''
    sed -i "/setuptools_git_ls_files/d" pyproject.toml
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    # import from $out
    mv src/python/compreffor/test .
    rm -r src tools
  '';

  build-system = [
    cython
    setuptools-scm
  ];

  dependencies = [ fonttools ];
  pyproject = true;
  pythonImportsCheck = [ "compreffor" ];

  meta = {
    description = "CFF table subroutinizer for FontTools";
    homepage = "https://github.com/googlefonts/compreffor";
    changelog = "https://github.com/googlefonts/compreffor/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "compreffor";
  };
}
