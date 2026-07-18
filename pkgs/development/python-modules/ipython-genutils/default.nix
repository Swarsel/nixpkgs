{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ipython-genutils";
  version = "0.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6y4RbnXs751NIo/cZq9UJpr6JqtEYwQuM3hbiHxii6g=";
    pname = "ipython_genutils";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-At0aq6rLw/L64Own069m0p/WQm7iDa24fm0SPLLRBdE=";
      name = "ipython_genutils-denose.patch";
      url = "https://build.opensuse.org/public/source/devel:languages:python:jupyter/python-ipython_genutils/denose.patch?rev=9";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "ipython_genutils" ];

  meta = {
    description = "Vestigial utilities from IPython";
    homepage = "https://ipython.org/";
    license = lib.licenses.bsd3;
  };
}
