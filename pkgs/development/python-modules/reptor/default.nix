{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  cvss,
  deepl,
  django,
  gql,
  pytestCheckHook,
  pyyaml,
  requests,
  rich,
  setuptools,
  sqlparse,
  termcolor,
  tomli,
  tomli-w,
  tomlkit,
  urllib3,
  writableTmpDirAsHomeHook,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "reptor";
  version = "0.34";

  src = fetchFromGitHub {
    owner = "Syslifters";
    repo = "reptor";
    tag = finalAttrs.version;
    hash = "sha256-L4w9QWyj+NyImQKLKWfdosLl+qytPqa+eyRw6p/4GgA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  preCheck = ''
    export PATH="$PATH:$out/bin";
  '';

  build-system = [ setuptools ];

  dependencies = [
    certifi
    cvss
    django
    pyyaml
    requests
    rich
    termcolor
    tomli
    tomli-w
    tomlkit
    urllib3
    xmltodict
  ];

  disabledTestMarks = [
    # Tests need network access
    "integration"
  ];

  optional-dependencies = {
    ghostwriter = [ gql ] ++ gql.optional-dependencies.aiohttp;
    translate = [ deepl ];
  };

  pyproject = true;
  pythonImportsCheck = [ "reptor" ];
  pythonRelaxDeps = true;

  meta = {
    description = "Module to do automated pentest reporting with SysReptor";
    homepage = "https://github.com/Syslifters/reptor";
    changelog = "https://github.com/Syslifters/reptor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "reptor";
  };
})
