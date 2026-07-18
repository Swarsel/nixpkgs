{
  lib,
  fetchFromGitHub,
  attrs,
  bibtexparser,
  buildPythonPackage,
  colorlog,
  git,
  lxml,
  markdown,
  markupsafe,
  postgresql,
  pylatexenc,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  setuptools,
  tabulate,
}:

buildPythonPackage rec {
  pname = "clldutils";
  version = "3.24.2";

  src = fetchFromGitHub {
    owner = "clld";
    repo = "clldutils";
    tag = "v${version}";
    hash = "sha256-xIs6Lq9iDdcM3j51F27x408oUldvy5nlvVdbrAS5Jz0=";
  };

  nativeCheckInputs = [
    postgresql
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    git
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    bibtexparser
    colorlog
    lxml
    markdown
    markupsafe
    pylatexenc
    python-dateutil
    tabulate
  ];

  pyproject = true;

  meta = {
    description = "Utilities for clld apps without the overhead of requiring pyramid, rdflib et al";
    homepage = "https://github.com/clld/clldutils";
    changelog = "https://github.com/clld/clldutils/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.asl20;
    broken = lib.versionOlder bibtexparser.version "2";
  };
}
