{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  zope-testrunner,
}:

buildPythonPackage rec {
  pname = "zope-deprecation";
  version = "6.0";

  src = fetchFromGitHub {
    owner = "zopefoundation";
    repo = "zope.deprecation";
    tag = version;
    hash = "sha256-N/+RtilRY/8NfhUjd/Y4T6dmZHt6PW4ofP1UE8Aj1e8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools ==" "setuptools >="
  '';

  nativeCheckInputs = [ zope-testrunner ];

  checkPhase = ''
    runHook preCheck

    zope-testrunner --test-path=src

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "zope.deprecation" ];
  pythonNamespaces = [ "zope" ];

  meta = {
    description = "Zope Deprecation Infrastructure";
    homepage = "https://github.com/zopefoundation/zope.deprecation";
    changelog = "https://github.com/zopefoundation/zope.deprecation/blob/${version}/CHANGES.rst";
    license = lib.licenses.zpl21;
    maintainers = [ ];
  };
}
