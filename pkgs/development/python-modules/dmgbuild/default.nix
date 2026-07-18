{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ds-store,
  importlib-resources,
  mac-alias,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dmgbuild";
  version = "1.6.7";

  src = fetchFromGitHub {
    owner = "dmgbuild";
    repo = "dmgbuild";
    tag = "v${version}";
    hash = "sha256-dJHUpMPsYTgJdR3FoIzrH6C/VLWXlktW3o8VXeHxey8=";
  };

  postPatch = ''
    # relax all deps
    substituteInPlace pyproject.toml \
      --replace-fail "==" ">="
  '';

  # require permissions to access TextEditor.app
  # https://github.com/dmgbuild/dmgbuild/blob/refs/tags/v1.6.2/tests/examples/settings.py#L17
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    ds-store
    importlib-resources
    mac-alias
  ];

  pyproject = true;

  pythonImportsCheck = [
    "dmgbuild"
  ];

  meta = {
    description = "MacOS command line utility to build disk images";
    homepage = "https://github.com/dmgbuild/dmgbuild";
    changelog = "https://github.com/dmgbuild/dmgbuild/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    platforms = lib.platforms.darwin;
    mainProgram = "dmgbuild";
  };
}
