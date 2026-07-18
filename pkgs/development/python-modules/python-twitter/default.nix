{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  filetype,
  future,
  hypothesis,
  pytestCheckHook,
  requests,
  requests-oauthlib,
  responses,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-twitter";
  version = "3.5";

  src = fetchFromGitHub {
    owner = "bear";
    repo = "python-twitter";
    rev = "v${version}";
    sha256 = "08ydmf6dcd416cvw6xq1wxsz6b9s21f2mf9fh3y4qz9swj6n9h8z";
  };

  patches = [
    # Fix tests. Remove with the next release
    (fetchpatch {
      sha256 = "008b1bd03wwngs554qb136lsasihql3yi7vlcacmk4s5fmr6klqw";
      url = "https://github.com/bear/python-twitter/commit/f7eb83d9dca3ba0ee93e629ba5322732f99a3a30.patch";
    })
  ];

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "'pytest-runner'" ""
  '';

  nativeCheckInputs = [
    pytestCheckHook
    responses
    hypothesis
  ];

  build-system = [ setuptools ];

  dependencies = [
    filetype
    future
    requests
    requests-oauthlib
  ];

  disabledTests = [
    # AttributeError: 'FileCacheTest' object has no attribute 'assert_'
    "test_filecache"
  ];

  pyproject = true;
  pythonImportsCheck = [ "twitter" ];

  meta = {
    description = "Python wrapper around the Twitter API";
    homepage = "https://github.com/bear/python-twitter";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
