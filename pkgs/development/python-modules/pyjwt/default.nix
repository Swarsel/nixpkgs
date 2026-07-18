{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  oauthlib,
  pytestCheckHook,
  setuptools,
  sphinx-rtd-theme,
  sphinxHook,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "pyjwt";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "jpadilla";
    repo = "pyjwt";
    tag = version;
    hash = "sha256-q4ynXCJVDsyZh70439dloyWgRTLVm+elDOahUVOT5vA=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    sphinxHook
    sphinx-rtd-theme
    zope-interface
  ];

  nativeCheckInputs = [ pytestCheckHook ] ++ (lib.concatAttrValues optional-dependencies);
  build-system = [ setuptools ];

  disabledTests = [
    # requires internet connection
    "test_get_jwt_set_sslcontext_default"
  ];

  optional-dependencies.crypto = [ cryptography ];
  pyproject = true;
  pythonImportsCheck = [ "jwt" ];

  passthru.tests = {
    inherit oauthlib;
  };

  meta = {
    description = "JSON Web Token implementation in Python";
    homepage = "https://github.com/jpadilla/pyjwt";
    changelog = "https://github.com/jpadilla/pyjwt/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prikhi ];
  };
}
