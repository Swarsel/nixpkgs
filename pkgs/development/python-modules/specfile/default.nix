{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flexmock,
  git,
  pytestCheckHook,
  rpm,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "specfile";
  version = "0.39.1";

  src = fetchFromGitHub {
    owner = "packit";
    repo = "specfile";
    tag = finalAttrs.version;
    hash = "sha256-z9HGnBLdtJ4uzm1DJFD0QN/DZNTdBbZcPx/kefCYnkc=";

    postFetch = ''
      # export-subst prevents reproducibility
      rm "$out/.git_archival.txt"
    '';
  };

  nativeCheckInputs = [
    git
    flexmock
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ rpm ];

  disabledTests = [
    # AssertionError
    "test_update_tag"
    "test_shell_expansions"
  ];

  pyproject = true;
  pythonImportsCheck = [ "specfile" ];

  meta = {
    description = "Library for parsing and manipulating RPM spec files";
    homepage = "https://github.com/packit/specfile";
    changelog = "https://github.com/packit/specfile/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
