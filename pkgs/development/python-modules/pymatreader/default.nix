{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  h5py,
  hatchling,
  numpy,
  pytestCheckHook,
  scipy,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "pymatreader";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "obob";
    repo = "pymatreader";
    tag = "v${version}";
    hash = "sha256-cDEGEvBSj3gmjA+8aXULwuBVk09BLQbA91CNAxgtiLA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'source = "regex_commit"' "" \
      --replace-fail '"hatch-regex-commit"' ""
  '';

  propagatedBuildInputs = [
    h5py
    numpy
    scipy
    xmltodict
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "pymatreader" ];

  meta = {
    description = "Python package to read all kinds and all versions of Matlab mat files";
    homepage = "https://gitlab.com/obob/pymatreader/";
    changelog = "https://gitlab.com/obob/pymatreader/-/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
