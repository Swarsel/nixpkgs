{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  colorlog,
  packaging,
  parse,
  pathspec,
  prompt-toolkit,
  psutil,
  pytestCheckHook,
  requests,
  resolvelib,
  ruamel-yaml,
  setuptools,
  typing-extensions,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "mcdreforged";
  version = "2.15.7";

  src = fetchFromGitHub {
    owner = "MCDReforged";
    repo = "MCDReforged";
    tag = "v${finalAttrs.version}";
    hash = "sha256-e1JrDh8Zio+TCVCVvH8tBE/tY5ja3Nr3dCQRJwRqYh4=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    colorama
    colorlog
    packaging
    parse
    pathspec
    prompt-toolkit
    psutil
    requests
    resolvelib
    ruamel-yaml
    typing-extensions
  ];

  pyproject = true;
  pythonRelaxDeps = [ "ruamel.yaml" ];

  meta = {
    description = "Minecraft server control tool";

    longDescription = ''
      MCDReforged (abbreviated as MCDR) is a tool which provides the
      management ability of the Minecraft server using custom plugin
      system.  It doesn't need to modify or mod the original Minecraft
      server at all.

      From in-game calculator, player high-light, to manipulate
      scoreboard, manage structure file and backup / load backup, you
      can implement these by using MCDR and related plugins.
    '';

    homepage = "https://mcdreforged.com";
    changelog = "https://github.com/MCDReforged/MCDReforged/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "mcdreforged";
  };
})
