{
  lib,
  fetchFromGitHub,
  bash,
  braceexpand,
  buildPythonPackage,
  click,
  discordpy,
  import-expression,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  tabulate,
  typing-extensions,
}:
buildPythonPackage (finalAttrs: {
  pname = "jishaku";
  version = "2.6.3";

  src = fetchFromGitHub {
    owner = "Gorialis";
    repo = "jishaku";
    tag = finalAttrs.version;
    hash = "sha256-8kSdzrut7LYjglpHc5dToOIQTrPsW4lVAeIWY4rzdmU=";
  };

  postPatch = ''
    substituteInPlace jishaku/shell.py \
      --replace-fail '"/bin/bash"' '"${lib.getExe bash}"'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [ setuptools ];

  dependencies = [
    discordpy
    click
    braceexpand
    tabulate
    import-expression
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "jishaku"
    "jishaku.repl"
    "jishaku.features"
  ];

  meta = {
    description = "Debugging and testing cog for discord.py bots";
    homepage = "https://jishaku.readthedocs.io/en/latest";
    changelog = "https://github.com/Gorialis/jishaku/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jishaku";
  };
})
