{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  fastapi,
  # dependencies
  pydantic,
  # build-system
  rustPlatform,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "openai-harmony";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "openai";
    repo = "harmony";
    rev = "v${version}";
    hash = "sha256-CaEldCrjBkjwsVeTzpiAFl/llAnUwJGTlU8Pt8YTV1E=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # Tests require internet access
  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-HeUK/S9nUDRTVkLf8CPrHfjBbyGZezZGu5P8XkfStVQ=";
  };

  dependencies = [
    pydantic
  ];

  optional-dependencies = {
    demo = [
      fastapi
      uvicorn
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "openai_harmony" ];

  meta = {
    description = "Renderer for the harmony response format to be used with gpt-oss";
    homepage = "https://github.com/openai/harmony";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
