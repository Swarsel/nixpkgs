{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pyperclip,
  pytest,
  rustPlatform,
  xclip,
  xvfb-run,
}:

buildPythonPackage (finalAttrs: {
  pname = "resvg-py";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "baseplate-admin";
    repo = "resvg-py";
    tag = finalAttrs.version;
    hash = "sha256-XYV3XVLZNlCGPvvYPtyr4UX+9yuXnV7ZWwqt2I/rxTc=";
  };

  nativeCheckInputs = [
    pytest
    pyperclip
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    xclip
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck
    ${lib.optionalString stdenv.hostPlatform.isLinux "xvfb-run"} python -m pytest ${lib.optionalString stdenv.hostPlatform.isDarwin "-k \"not test_multiple_layer_svg\""}
    runHook postCheck
  '';

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-v7Y+Kh8Z5S5gn8zoijjwKq8UZGT36azltC62m9xCHiY=";
  };

  pyproject = true;

  pythonImportsCheck = [
    "resvg_py"
  ];

  meta = {
    description = "High level wrapper of resvg for python";
    homepage = "https://github.com/baseplate-admin/resvg-py";
    changelog = "https://github.com/baseplate-admin/resvg-py/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
