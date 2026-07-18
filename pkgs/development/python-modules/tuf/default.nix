{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  ed25519,
  # build-system
  flit-core,
  freezegun,
  hatchling,
  pytestCheckHook,
  # dependencies
  requests,
  securesystemslib,
}:

buildPythonPackage (finalAttrs: {
  pname = "tuf";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "theupdateframework";
    repo = "python-tuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CPbZOpUYi7MWKLMj7kwTsmEkxLCf4wU7IOCcbzMkPlU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "hatchling==1.27.0" "hatchling"
  '';

  nativeCheckInputs = [
    ed25519
    freezegun
    pytestCheckHook
  ];

  preCheck = ''
    cd tests
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    flit-core
    hatchling
  ];

  dependencies = [
    requests
    securesystemslib
  ]
  ++ securesystemslib.optional-dependencies.pynacl
  ++ securesystemslib.optional-dependencies.crypto;

  pyproject = true;
  pythonImportsCheck = [ "tuf" ];

  meta = {
    description = "Python reference implementation of The Update Framework (TUF)";
    homepage = "https://github.com/theupdateframework/python-tuf";
    changelog = "https://github.com/theupdateframework/python-tuf/blob/${finalAttrs.src.tag}/docs/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
})
