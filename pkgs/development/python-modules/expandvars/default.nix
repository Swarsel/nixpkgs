{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  # build-system
  hatchling,
  pytest-cov-stub,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "expandvars";
  version = "1.1.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bFgit7dWqZo1a5Fd0SZ/UquKTvqhNZY71/S9XTaPcdc=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-raO5dGbcXb0adUCeHmnWp49vpIMllRW9Ow8rG4OH+Hs=";
      name = "pytest9-compat.patch";
      url = "https://github.com/sayanarijit/expandvars/commit/0ab5747185be9135b0711e72fc64dfa6a33f3fd3.patch";
    })
  ];

  nativeBuildInputs = [ hatchling ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "expandvars" ];

  meta = {
    description = "Expand system variables Unix style";
    homepage = "https://github.com/sayanarijit/expandvars";
    license = lib.licenses.mit;
  };
}
