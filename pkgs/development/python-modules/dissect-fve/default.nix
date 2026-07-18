{
  lib,
  fetchFromGitHub,
  argon2-cffi,
  buildPythonPackage,
  dissect-cstruct,
  dissect-target,
  dissect-util,
  pycryptodome,
  rich,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "dissect-fve";
  version = "4.6";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.fve";
    tag = version;
    hash = "sha256-VNkMqnv0LFvqVIQzk086o4UDH3bcK3HgF0HdYmhpNgY=";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    argon2-cffi
    dissect-cstruct
    dissect-util
    pycryptodome
  ];

  optional-dependencies = {
    full = [
      dissect-target
      rich
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dissect.fve" ];

  meta = {
    description = "Dissect module implementing parsers for full volume encryption implementations";
    homepage = "https://github.com/fox-it/dissect.fve";
    changelog = "https://github.com/fox-it/dissect.fve/releases/tag/${src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
}
