{
  lib,
  fetchFromGitHub,
  fetchpatch,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rich-cli";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "Textualize";
    repo = "rich-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z1Ea8f8QNgy2CWGyQWgY2Y/tpg269R5n9Qrs1YhCHa8=";
  };

  postPatch = ''
    substituteInPlace src/rich_cli/__main__.py \
      --replace-fail 'VERSION = "1.8.0"' 'VERSION = "1.8.1"'
  '';

  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    click
    requests
    rich
    rich-rst
    textual
  ];

  pyproject = true;
  pythonImportsCheck = [ "rich_cli" ];

  pythonRelaxDeps = [
    "rich"
    "textual"
    "rich-rst"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/rich";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Command Line Interface to Rich";
    homepage = "https://github.com/Textualize/rich-cli";
    changelog = "https://github.com/Textualize/rich-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rich";
  };
})
