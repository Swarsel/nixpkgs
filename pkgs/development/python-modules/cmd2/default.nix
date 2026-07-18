{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  gnureadline,
  pyperclip,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  rich-argparse,
  setuptools-scm,
  wcwidth,
}:

buildPythonPackage rec {
  pname = "cmd2";
  version = "3.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bGNyobJs0Uu2IJZTyJ1zAP58FDno3KMPW2tv/bXyFPo=";
  };

  doCheck = true;

  nativeCheckInputs = [
    glibcLocales
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
  ];

  build-system = [ setuptools-scm ];

  dependencies = [
    pyperclip
    rich-argparse
    wcwidth
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin gnureadline;

  disabledTests = [
    # Don't require vim for tests, it causes lots of rebuilds
    "test_find_editor_not_specified"
    "test_transcript"
    # Removed upstream after rich 15 update
    "test_from_ansi_wrapper"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cmd2" ];

  meta = {
    description = "Enhancements for standard library's cmd module";
    homepage = "https://github.com/python-cmd2/cmd2";
    changelog = "https://github.com/python-cmd2/cmd2/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ teto ];
  };
}
