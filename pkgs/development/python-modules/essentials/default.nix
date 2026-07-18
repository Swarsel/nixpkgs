{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "essentials";
  version = "1.1.9";

  src = fetchFromGitHub {
    owner = "Neoteroi";
    repo = "essentials";
    tag = "v${version}";
    hash = "sha256-kKAXCtcl6duVpuGDnSqVfJmfltv9ybU8Gmr3y32Dg9I=";
  };

  nativeCheckInputs = [
    pydantic
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # time.sleep(0.01) can be up to 0.05s on darwin
    "test_stopwatch"
    "test_stopwatch_with_context_manager"
  ];

  pyproject = true;
  pythonImportsCheck = [ "essentials" ];

  meta = {
    description = "General purpose classes and functions";
    homepage = "https://github.com/Neoteroi/essentials";
    changelog = "https://github.com/Neoteroi/essentials/releases/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      aldoborrero
      zimbatm
    ];
  };
}
