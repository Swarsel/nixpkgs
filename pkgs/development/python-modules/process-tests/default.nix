{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  setuptools,
}:

buildPythonPackage rec {
  pname = "process-tests";
  version = "3.0.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5dV96nFhJR6RytuEvz7MhSdfsSH9R45Xn4AHd7HUJL0=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-LbLaDXHbywvsq++lklNiLw8u0USuiEpuxzpNMhXBWtE=";
      # Add optional ignore_case param to wait_for_strings
      url = "https://github.com/ionelmc/python-process-tests/commit/236c3e83722a36eddb4abb111a2fcceb49cc9ab7.patch";
    })
  ];

  nativeBuildInputs = [ setuptools ];
  # No tests
  doCheck = false;
  pyproject = true;

  meta = {
    description = "Tools for testing processes";
    homepage = "https://github.com/ionelmc/python-process-tests";
    license = lib.licenses.bsd2;
  };
}
