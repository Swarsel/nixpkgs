{
  lib,
  fetchFromGitHub,
  # dependencies
  appdirs,
  babelfish,
  buildPythonPackage,
  chardet,
  click,
  jsonschema,
  # build dependencies
  poetry-core,
  pysrt,
  # tests
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "cleanit";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "ratoaq2";
    repo = "cleanit";
    tag = version;
    hash = "sha256-5fzBcOr6PGp847S7qLsXgYKxPcGW4mM5B5QNBSvH7BM=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    appdirs
    babelfish
    chardet
    click
    jsonschema
    pysrt
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "cleanit" ];
  pythonRelaxDeps = [ "chardet" ];

  meta = {
    description = "Command line tool that helps you to keep your subtitles clean";
    homepage = "https://github.com/ratoaq2/cleanit";
    changelog = "https://github.com/ratoaq2/cleanit/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "cleanit";
  };
}
