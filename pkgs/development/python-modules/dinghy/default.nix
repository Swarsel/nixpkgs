{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  backports-datetime-fromisoformat,
  buildPythonPackage,
  click,
  click-log,
  emoji,
  freezegun,
  glom,
  jinja2,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dinghy";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "nedbat";
    repo = "dinghy";
    tag = version;
    hash = "sha256-51BXQdDxlI6+3ctDSa/6tyRXBb1E9BVej9qy7WtkOGM=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    aiofiles
    aiohttp
    backports-datetime-fromisoformat
    click
    click-log
    emoji
    glom
    jinja2
    pyyaml
  ];

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "dinghy.cli" ];

  meta = {
    description = "GitHub activity digest tool";
    homepage = "https://github.com/nedbat/dinghy";
    changelog = "https://github.com/nedbat/dinghy/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      trundle
      veehaitch
    ];

    mainProgram = "dinghy";
  };
}
