{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "oelint-adv";
  version = "9.9.2";

  src = fetchFromGitHub {
    owner = "priv-kweihmann";
    repo = "oelint-adv";
    tag = finalAttrs.version;
    hash = "sha256-RHW5GfTtwF7vEvnxTU+OyEMgMm0q3w+IjH0u6A3xQh0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "--random-order-bucket=global" "" \
      --replace-fail "--random-order"               "" \
      --replace-fail "--force-sugar"                "" \
      --replace-fail "--old-summary"                ""
  '';

  nativeCheckInputs = with python3Packages; [
    pytest-cov-stub
    pytest-forked
    pytest-xdist
    pytestCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    anytree
    argcomplete
    colorama
    oelint-data
    oelint-parser
    urllib3
  ];

  disabledTests = [
    # requires network access
    "TestClassOelintVarsHomepagePing"
  ];

  pyproject = true;
  pythonImportsCheck = [ "oelint_adv" ];

  pythonRelaxDeps = [
    "argcomplete"
    "urllib3"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Advanced bitbake-recipe linter";
    homepage = "https://github.com/priv-kweihmann/oelint-adv";
    changelog = "https://github.com/priv-kweihmann/oelint-adv/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ otavio ];
    mainProgram = "oelint-adv";
  };
})
