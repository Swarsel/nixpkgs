{
  lib,
  betamax,
  betamax-matchers,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  hatchling,
  pyjwt,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  requests,
  uritemplate,
}:

buildPythonPackage rec {
  pname = "github3-py";
  version = "4.0.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-MNVxB2dT78OJ7cf5qu8zik/LJLVNiWjV85sTQvRd3TY=";
    pname = "github3.py";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-8Z4vN7iKl/sOcEJptsH5jsqijZgvL6jS7kymZ8+m6bY=";
      # disable tests with "AttributeError: 'MockHTTPResponse' object has no attribute 'close'", due to betamax
      url = "https://github.com/sigmavirus24/github3.py/commit/9d6124c09b0997b5e83579549bcf22b3e901d7e5.patch";
    })
  ];

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    betamax
    betamax-matchers
  ];

  build-system = [ hatchling ];

  dependencies = [
    pyjwt
    python-dateutil
    requests
    uritemplate
  ]
  ++ pyjwt.optional-dependencies.crypto;

  pyproject = true;
  pythonImportsCheck = [ "github3" ];

  meta = {
    description = "Wrapper for the GitHub API written in python";
    homepage = "https://github3py.readthedocs.org/en/master/";
    changelog = "https://github.com/sigmavirus24/github3.py/blob/${version}/docs/source/release-notes/${version}.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pSub ];
  };
}
