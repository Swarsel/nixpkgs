{
  lib,
  stdenv,
  fetchFromGitHub,
  assertpy,
  buildPythonPackage,
  chardet,
  colorama,
  cucumber-expressions,
  cucumber-tag-expressions,
  freezegun,
  mock,
  parse,
  parse-type,
  path,
  pyhamcrest,
  pytest-html,
  pytestCheckHook,
  python,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "behave";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "behave";
    repo = "behave";
    tag = "v${version}";
    hash = "sha256-sHsnBeyl0UJ0f7WcTUc+FhUxATh84RPxVE3TqGYosrs=";
  };

  postPatch = ''
    patchShebangs bin
  '';

  nativeCheckInputs = [
    pytestCheckHook
    assertpy
    chardet
    freezegun
    mock
    path
    pyhamcrest
    pytest-html
  ];

  # -e disables tags.help.feature from being executed (due to stdout formatting differences)
  postCheck = ''
    ${python.interpreter} bin/behave -f progress3 --stop --tags='~@xfail' \
      -e tags.help.feature \
      features/
    ${python.interpreter} bin/behave -f progress3 --stop --tags='~@xfail' tools/test-features/
    ${python.interpreter} bin/behave -f progress3 --stop --tags='~@xfail' issue.features/
  '';

  build-system = [ setuptools ];

  dependencies = [
    colorama
    cucumber-expressions
    cucumber-tag-expressions
    parse
    parse-type
    six
  ];

  # timing-based test flaky on Darwin
  # https://github.com/NixOS/nixpkgs/pull/97737#issuecomment-691489824
  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    "test_step_decorator_async_run_until_complete"
  ];

  pyproject = true;
  pythonImportsCheck = [ "behave" ];

  meta = {
    description = "Behaviour-driven development, Python style";
    homepage = "https://github.com/behave/behave";
    changelog = "https://github.com/behave/behave/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      alunduil
      maxxk
    ];

    mainProgram = "behave";
  };
}
