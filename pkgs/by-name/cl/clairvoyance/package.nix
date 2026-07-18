{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "clairvoyance";
  version = "2.5.5";

  src = fetchFromGitHub {
    owner = "nikitastupin";
    repo = "clairvoyance";
    tag = "v${finalAttrs.version}";
    hash = "sha256-anUceLMTeHQ/Z0+MjKL0alDdKaWA5y3HpJC81MBTTq8=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'asyncio = "^3.4.3"' ""
  '';

  nativeCheckInputs = with python3.pkgs; [
    aiounittest
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    aiohttp
    rich
  ];

  disabledTests = [
    # KeyError
    "test_probe_typename"
  ];

  pyproject = true;
  pythonImportsCheck = [ "clairvoyance" ];
  pythonRelaxDeps = [ "rich" ];

  meta = {
    description = "Tool to obtain GraphQL API schemas";
    homepage = "https://github.com/nikitastupin/clairvoyance";
    changelog = "https://github.com/nikitastupin/clairvoyance/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "clairvoyance";
  };
})
