{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  bash,
  buildPythonPackage,
  docstring-parser,
  fish,
  hatch-vcs,
  hatchling,
  markdown,
  mkdocs,
  pexpect,
  pydantic,
  pymdown-extensions,
  pytest-cov-stub,
  pytest-mock,
  pytestCheckHook,
  pyyaml,
  rich,
  rich-rst,
  sphinx,
  syrupy,
  trio,
  zsh,
}:

buildPythonPackage (finalAttrs: {
  pname = "cyclopts";
  version = "4.20.0";

  src = fetchFromGitHub {
    owner = "BrianPugh";
    repo = "cyclopts";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zmvqpRJGZnfmhOiHwYogMbqLaAkfIG34CFbRXUUEr0E=";
  };

  nativeCheckInputs = [
    pexpect
    pydantic
    pytest-cov-stub
    pytest-mock
    pytestCheckHook
    syrupy

    # integrations
    sphinx
    bash
    fish
    zsh
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    attrs
    docstring-parser
    rich
    rich-rst
  ];

  disabledTests = [
    # Building docs
    "build_succeeds"
    # timeouts under heavy concurrency
    "test_behavior[zsh-root-subcommands]"
    "test_behavior[zsh-subcommand-prefix]"
    "test_path_completion_action"
    "test_requires_equals_eq_form_value_completion"
  ];

  optional-dependencies = {
    mkdocs = [
      mkdocs
      markdown
      pymdown-extensions
    ];

    trio = [ trio ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cyclopts" ];
  pythonRelaxDeps = [ "rich-rst" ];

  meta = {
    description = "Module to create CLIs based on Python type hints";
    homepage = "https://github.com/BrianPugh/cyclopts";
    changelog = "https://github.com/BrianPugh/cyclopts/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      fab
      PerchunPak
    ];
  };
})
