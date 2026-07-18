{
  lib,
  nixosTests,
  python312Packages,
}:

let
  python3Packages = python312Packages;
in
python3Packages.buildPythonApplication (finalAttrs: {
  inherit (python3Packages.nipap) version src;
  pname = "nipap-cli";

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'docutils==0.20.1' 'docutils'
  '';

  checkInputs = with python3Packages; [
    pythonImportsCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
    docutils
  ];

  dependencies = with python3Packages; [
    ipy
    pynipap
  ];

  pyproject = true;

  pythonImportsCheck = [
    "nipap_cli.nipap_cli"
  ];

  sourceRoot = "${finalAttrs.src.name}/nipap-cli";
  passthru.tests.nixos = nixosTests.nipap;

  meta = {
    description = "Neat IP Address Planner CLI";

    longDescription = ''
      NIPAP is the best open source IPAM in the known universe,
      challenging classical IP address management (IPAM) systems in many areas.
    '';

    homepage = "https://github.com/SpriteLink/NIPAP";
    changelog = "https://github.com/SpriteLink/NIPAP/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lukegb
    ];

    platforms = lib.platforms.all;
    mainProgram = "nipap";
  };
})
