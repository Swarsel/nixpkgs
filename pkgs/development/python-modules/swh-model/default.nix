{
  lib,
  stdenv,
  fetchFromGitLab,
  aiohttp,
  attrs,
  attrs-strict,
  buildPythonPackage,
  click,
  dateutils,
  deprecated,
  dulwich,
  hypothesis,
  iso8601,
  pytestCheckHook,
  pytz,
  setuptools,
  setuptools-scm,
  types-click,
  types-deprecated,
  types-python-dateutil,
  types-pytz,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-model";
  version = "8.4.1";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-model";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v/vbY0mxvsbuLUAmDACW9brfVF5djMYyvv9Mf1VL6do=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  nativeCheckInputs = [
    aiohttp
    click
    pytestCheckHook
    pytz
    types-click
    types-python-dateutil
    types-pytz
    types-deprecated
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    attrs
    attrs-strict
    click
    dulwich
    dateutils
    deprecated
    hypothesis
    iso8601
    typing-extensions
  ];

  disabledTestPaths = lib.optionals (stdenv.hostPlatform.isDarwin) [
    # OSError: [Errno 92] Illegal byte sequence
    "swh/model/tests/test_cli.py::TestIdentify::test_exclude"
    "swh/model/tests/test_from_disk.py::DirectoryToObjects::test_exclude"
    "swh/model/tests/test_from_disk.py::DirectoryToObjects::test_exclude_trailing"
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.model" ];

  meta = {
    description = "Implementation of the Data model of the Software Heritage project, used to archive source code artifacts";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-model";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
