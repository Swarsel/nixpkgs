{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "bidict";
  version = "0.23.1";

  src = fetchFromGitHub {
    owner = "jab";
    repo = "bidict";
    tag = "v${version}";
    hash = "sha256-WE0YaRT4a/byvU2pzcByuf1DfMlOpYA9i0PPrKXsS+M=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-xdist
    pytestCheckHook
    typing-extensions
  ];

  # Remove the bundled pytest.ini, which adds options to run additional integration
  # tests that are overkill for our purposes.
  preCheck = ''
    rm pytest.ini
  '';

  build-system = [
    setuptools
    wheel
  ];

  pyproject = true;
  pythonImportsCheck = [ "bidict" ];

  meta = {
    description = "Bidirectional mapping library for Python";
    homepage = "https://bidict.readthedocs.io";
    changelog = "https://bidict.readthedocs.io/changelog.html";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      jab
      jakewaksbaum
    ];
  };
}
