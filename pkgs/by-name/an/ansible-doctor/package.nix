{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ansible-doctor";
  version = "8.3.3";

  src = fetchFromGitHub {
    owner = "thegeeklab";
    repo = "ansible-doctor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3xdMTuy6Rtb2VwfzN6SV73UZmp+9fmU9SfPySHCayJg=";
  };

  doCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  build-system = with python3Packages; [
    poetry-core
    poetry-dynamic-versioning
  ];

  dependencies = with python3Packages; [
    anyconfig
    appdirs
    colorama
    dynaconf
    environs
    gitpython
    jinja2
    jsonschema
    nested-lookup
    pathspec
    python-json-logger
    ruamel-yaml
    structlog
  ];

  pyproject = true;
  pythonImportsCheck = [ "ansibledoctor" ];
  pythonRelaxDeps = true;
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Annotation based documentation for your Ansible roles";
    homepage = "https://github.com/thegeeklab/ansible-doctor";
    changelog = "https://github.com/thegeeklab/ansible-doctor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ tboerger ];
    mainProgram = "ansible-doctor";
  };
})
