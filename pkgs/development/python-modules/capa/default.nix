{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  deptry,
  dncil,
  dnfile,
  humanize,
  ida-netnode,
  ida-settings,
  jschema-to-python,
  msgspec,
  mypy,
  mypy-protobuf,
  networkx,
  pefile,
  protobuf,
  psutil,
  pydantic,
  pyelftools,
  pyghidra,
  pygithub,
  pytest-instafail,
  pytest-sugar,
  pytestCheckHook,
  python-flirt,
  pyyaml,
  requests,
  rich,
  ruamel-yaml,
  sarif-om,
  setuptools,
  setuptools-scm,
  stix2,
  types-colorama,
  types-protobuf,
  types-psutil,
  types-pyyaml,
  types-requests,
  viv-utils,
  vivisect,
  writableTmpDirAsHomeHook,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "capa";
  version = "9.4.0";

  src = fetchFromGitHub {
    owner = "mandiant";
    repo = "capa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h9ML+TJe9NprBEy4W7XKahmUTM0d4vY0zIFs6MxYzZ8=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pygithub
    pytestCheckHook
    pytest-instafail
    pytest-sugar
    types-colorama
    types-protobuf
    types-psutil
    types-pyyaml
    types-requests
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    colorama
    dncil
    dnfile
    humanize
    ida-netnode
    ida-settings
    msgspec
    networkx
    pefile
    protobuf
    pydantic
    pyelftools
    python-flirt
    pyyaml
    rich
    ruamel-yaml
    viv-utils
    vivisect
    xmltodict
  ];

  disabledTests = [
    # AssertionError
    "test_is_dev_environment"
    "test_rule_cache_dev_environment"
    "test_scripts"
    "test_binexport_scripts"
  ];

  optional-dependencies = {
    ghidra = [ pyghidra ];

    scripts = [
      jschema-to-python
      psutil
      requests
      sarif-om
      stix2
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "capa" ];

  meta = {
    description = "Tool to identify capabilities in executable files";
    homepage = "https://github.com/mandiant/capa";
    changelog = "https://github.com/mandiant/capa/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "capa";
  };
})
