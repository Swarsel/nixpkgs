{
  lib,
  buildPythonPackage,
  factory-boy,
  faker,
  fetchPypi,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "tld";
  version = "0.13.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-2YP6krnXF0AHQvyoROKdXhgnEHnHvPq/ZtAbObShQ0U=";
  };

  doCheck = false; # missing pytest-codeblock

  nativeCheckInputs = [
    factory-boy
    faker
    pytest-cov-stub
    pytestCheckHook
  ];

  # These tests require network access, but disabledTestPaths doesn't work.
  # the file needs to be `import`ed by another Python test file, so it
  # can't simply be removed.
  preCheck = ''
    echo > src/tld/tests/test_commands.py
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "tld" ];

  meta = {
    description = "Extracts the top level domain (TLD) from the URL given";
    homepage = "https://github.com/barseghyanartur/tld";
    changelog = "https://github.com/barseghyanartur/tld/blob/${version}/CHANGELOG.rst";

    # https://github.com/barseghyanartur/tld/blob/master/README.rst#license
    # MPL-1.1 OR GPL-2.0-only OR LGPL-2.1-or-later
    license = with lib.licenses; [
      lgpl21Plus
      mpl11
      gpl2Only
    ];

    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "update-tld-names";
  };
}
