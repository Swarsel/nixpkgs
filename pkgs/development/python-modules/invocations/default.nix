{
  lib,
  fetchFromGitHub,
  blessed,
  build,
  buildPythonPackage,
  icecream,
  invoke,
  pip,
  pytest-mock,
  pytest-relaxed,
  pytestCheckHook,
  releases,
  semantic-version,
  setuptools,
  tabulate,
  tqdm,
  twine,
}:

buildPythonPackage rec {
  pname = "invocations";
  version = "4.0.2";

  src = fetchFromGitHub {
    owner = "pyinvoke";
    repo = "invocations";
    tag = version;
    hash = "sha256-G6EKypqP2/coPChLwwEKZ2WIEay0qfyM8M5jKb0oS2c=";
  };

  patches = [ ./replace-blessings-with-blessed.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "semantic_version>=2.4,<2.7" "semantic_version"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-relaxed
    pytest-mock
    icecream
    pip
  ];

  build-system = [ setuptools ];

  dependencies = [
    build
    blessed
    invoke
    releases
    semantic-version
    tabulate
    tqdm
    twine
  ];

  disabledTests = [
    # invoke.exceptions.UnexpectedExit
    "autodoc_"

    # ValueError: Call either Version('1.2.3') or Version(major=1, ...)
    "component_state_enums_contain_human_readable_values"
    "load_version_"
    "prepare_"
    "status_"
  ];

  pyproject = true;
  pythonImportsCheck = [ "invocations" ];

  meta = {
    description = "Common/best-practice Invoke tasks and collections";
    homepage = "https://invocations.readthedocs.io/";
    changelog = "https://github.com/pyinvoke/invocations/blob/${src.tag}/docs/changelog.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ samuela ];
  };
}
