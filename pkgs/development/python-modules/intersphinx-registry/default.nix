{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  flit-core,
  mypy,
  # optional-dependencies
  platformdirs,
  pytest,
  pytest-xdist,
  # tests
  pytestCheckHook,
  requests,
  requests-cache,
  sphinx,
  types-requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "intersphinx-registry";
  version = "0.2705.27";

  src = fetchFromGitHub {
    owner = "Quansight-labs";
    repo = "intersphinx_registry";
    tag = finalAttrs.version;
    hash = "sha256-yFpk3NZO2iCjuJ43WvssbDYxNJ6G6KfY5pcTCilsGQs=";
  };

  # TODO: lots of failing tests
  doCheck = false;

  nativeCheckInputs = [
    mypy
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.tests;

  __structuredAttrs = true;

  build-system = [
    flit-core
  ];

  dependencies = finalAttrs.passthru.optional-dependencies.lookup;

  optional-dependencies = {
    lookup = [
      platformdirs
      requests
      requests-cache
      sphinx
    ];

    tests = [
      mypy
      pytest
      pytest-xdist
      types-requests
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "intersphinx_registry"
  ];

  meta = {
    description = "Utility package that provides a default intersphinx mapping";
    homepage = "https://github.com/Quansight-labs/intersphinx_registry";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eljamm ];
    mainProgram = "intersphinx-registry";
  };
})
