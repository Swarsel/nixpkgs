{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "ninjavis";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "chagui";
    repo = "ninjavis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4MXU43noG0mKwiXWrLu1tW9YGkU1YjP/UoUKZzVer14=";
  };

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    env --ignore-environment $out/bin/ninjavis --help

    runHook postInstallCheck
  '';

  build-system = [
    python3Packages.poetry-core
  ];

  pyproject = true;

  pythonImportsCheck = [
    "ninjavis"
  ];

  meta = {
    description = "Generate visualization from Ninja build logs";
    homepage = "https://github.com/chagui/ninjavis";
    changelog = "https://github.com/chagui/ninjavis/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pbsds ];
    mainProgram = "ninjavis";
  };
})
