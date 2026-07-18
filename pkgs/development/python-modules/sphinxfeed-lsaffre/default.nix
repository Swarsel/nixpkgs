{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  feedgen,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
  python-dateutil,
  sphinx,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinxfeed-lsaffre";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "lsaffre";
    repo = "sphinxfeed";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2hS8EzaUlxAqBT0R5NMYAuj3ZMPq+x5nqJnidQOAGfM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    feedgen
    python-dateutil
    sphinx
  ];

  pyproject = true;

  pythonImportsCheck = [
    "sphinxfeed"
  ];

  meta = {
    description = "Automatically generates an RSS feed when a build is run";
    homepage = "https://github.com/lsaffre/sphinxfeed";
    changelog = "https://github.com/lsaffre/sphinxfeed/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.antonmosich ];
  };
})
