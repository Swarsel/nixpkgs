{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fixtures,
  less,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "autopage";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "zaneb";
    repo = "autopage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oBZoGVvgUhrfcEUvmhIN7Wnsv+SvkC553LAhHGCVIBQ=";
  };

  nativeCheckInputs = [
    fixtures
    less
    pytestCheckHook
  ]
  ++ fixtures.optional-dependencies.streams;

  build-system = [ setuptools ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # https://github.com/zaneb/autopage/issues/7
    "test_end_to_end"
  ];

  pyproject = true;
  pythonImportsCheck = [ "autopage" ];

  meta = {
    description = "Library to provide automatic paging for console output";
    homepage = "https://github.com/zaneb/autopage";
    changelog = "https://github.com/zaneb/autopage/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    teams = [ lib.teams.openstack ];
  };
})
