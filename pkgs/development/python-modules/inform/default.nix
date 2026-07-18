{
  lib,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  flit-core,
  hypothesis,
  num2words,
  pytestCheckHook,
  pythonAtLeast,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "inform";
  version = "1.37";

  src = fetchFromGitHub {
    owner = "KenKundert";
    repo = "inform";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qj7znEKNFKUjHHGy1TCfO4YtYV3kJ4AzBSdzsJC6kpQ=";
  };

  nativeCheckInputs = [
    num2words
    pytestCheckHook
    hypothesis
  ];

  build-system = [ flit-core ];

  dependencies = [
    arrow
    six
  ];

  disabledTests = [
    "test_prostrate"
  ]
  ++ lib.optionals (pythonAtLeast "3.13") [
    # doctest runs one more test than expected
    "test_inform"
  ];

  pyproject = true;

  meta = {
    description = "Print and logging utilities";

    longDescription = ''
      Inform is designed to display messages from programs that are typically
      run from a console. It provides a collection of ‘print’ functions that
      allow you to simply and cleanly print different types of messages.
    '';

    homepage = "https://inform.readthedocs.io";
    changelog = "https://github.com/KenKundert/inform/blob/${finalAttrs.src.tag}/doc/releases.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ jeremyschlatter ];
  };
})
