{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  holoviews,
  ipykernel,
  jupyter-client,
  nbconvert,
  nbformat,
  pyflakes,
  pytest,
  requests,
}:

buildPythonPackage rec {
  pname = "nbsmoke";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "8b55333e2face27bc7ff80c266c468ca5633947cb0697727348020dd445b0874";
  };

  propagatedBuildInputs = [
    pytest
    holoviews
    jupyter-client
    ipykernel
    nbformat
    nbconvert
    pyflakes
    requests
    beautifulsoup4
  ];

  # tests not included with pypi release
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "nbsmoke" ];

  meta = {
    description = "Basic notebook checks and linting";
    homepage = "https://github.com/pyviz/nbsmoke";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
