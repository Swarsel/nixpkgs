{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  chameleon,
  colander,
  coverage,
  fetchPypi,
  flaky,
  iso8601,
  peppercorn,
  pyramid,
  pytestCheckHook,
  setuptools,
  translationstring,
  zope-deprecation,
}:

buildPythonPackage rec {
  pname = "deform";
  version = "2.0.15";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-HpEpN2UMHbuDAHndnAOZUHYqIwIjpWd0D78bI/EJA2c=";
  };

  nativeCheckInputs = [
    coverage
    beautifulsoup4
    flaky
    pyramid
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    chameleon
    colander
    iso8601
    peppercorn
    translationstring
    zope-deprecation
  ];

  pyproject = true;

  meta = {
    description = "Form library with advanced features like nested forms";
    homepage = "https://docs.pylonsproject.org/projects/deform/en/latest/";

    # https://github.com/Pylons/deform/blob/fdc43d59de7d11b0e3ba1b92835b780cfe181719/LICENSE.txt
    license = [
      lib.licenses.bsd3
      lib.licenses.cc-by-30
    ];

    maintainers = [ ];
  };
}
