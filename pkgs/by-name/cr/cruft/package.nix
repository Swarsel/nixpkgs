{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cruft";
  version = "2.16.0";

  src = fetchFromGitHub {
    owner = "cruft";
    repo = "cruft";
    tag = finalAttrs.version;
    hash = "sha256-hUucSfgDBlT5jVk/oF8JjbcYhjHgkprfGRwsSNfgjfg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "0.0.0"' 'version = "${finalAttrs.version}"'
  '';

  nativeCheckInputs = with python3Packages; [
    pytest7CheckHook
  ];

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = with python3Packages; [
    click
    cookiecutter
    gitpython
    typer
  ];

  disabledTestPaths = [
    "tests/test_api.py" # only 2 tests pass, and 24 fail. I am going to ignore entire file
    "tests/test_cli.py"
  ];

  # Unfortunately, some tests require internet access to fully clone
  # https://github.com/cruft/cookiecutter-test (including all branches)
  # which is possible to package, but is annoying and may be not always pure
  #
  # See https://discourse.nixos.org/t/keep-git-folder-in-when-fetching-a-git-repo/8590/6
  #
  # There are only 13 tests which do not require internet access on moment of the writing.
  # But some tests are better than none, right?
  disabledTests = [
    "test_get_diff_with_add"
    "test_get_diff_with_delete"
    "test_get_diff_with_unicode"
  ];

  pyproject = true;
  pythonImportsCheck = "cruft";

  meta = {
    description = "Allows you to maintain all the necessary boilerplate for building projects";
    homepage = "https://github.com/cruft/cruft";
    changelog = "https://github.com/cruft/cruft/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ PerchunPak ];
    mainProgram = "cruft";
  };
})
