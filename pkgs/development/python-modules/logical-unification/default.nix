{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  multipledispatch,
  py,
  pytest-benchmark,
  pytest-html,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  toolz,
}:

buildPythonPackage (finalAttrs: {
  pname = "logical-unification";
  version = "0.4.7";

  src = fetchFromGitHub {
    owner = "pythological";
    repo = "unification";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m1wB7WOGb/io4Z7Zfl/rckh08j6IKSiiwFKMvl5UzHg=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-0y1DHxxjQ19upOlstf/zihP1b6iQ4A/WqyWNpirW/kg=";
      url = "https://github.com/pythological/unification/pull/49.patch";
    })
  ];

  nativeCheckInputs = [
    py
    pytestCheckHook
    pytest-html
    pytest-benchmark # Needed for the `--benchmark-skip` flag
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    toolz
    multipledispatch
  ];

  pyproject = true;

  pytestFlags = [
    "--benchmark-skip"
    "--html=testing-report.html"
    "--self-contained-html"
  ];

  pythonImportsCheck = [ "unification" ];

  meta = {
    description = "Straightforward unification in Python that's extensible via generic functions";
    homepage = "https://github.com/pythological/unification";
    changelog = "https://github.com/pythological/unification/releases";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ Etjean ];
  };
})
