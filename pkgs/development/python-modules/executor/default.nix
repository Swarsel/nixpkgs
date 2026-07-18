{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coloredlogs,
  fasteners,
  fetchpatch2,
  humanfriendly,
  mock,
  property-manager,
  pytestCheckHook,
  setuptools,
  six,
  virtualenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "executor";
  version = "23.2";

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-executor";
    tag = finalAttrs.version;
    hash = "sha256-Gjv+sUtnP11cM8GMGkFzXHVx0c2XXSU56L/QwoQxINc=";
  };

  patches = [
    # https://github.com/xolox/python-executor/pull/26
    (fetchpatch2 {
      hash = "sha256-pfWdLaREikzBaey75Tb+GiE+pUCl1h2OmsjlpzKOlno=";
      name = "python313-compat.patch";
      url = "https://github.com/xolox/python-executor/commit/4c5f4b44543bfb48ad790c440d1d7d0933e12499.patch?full_index=1";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
    virtualenv
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    coloredlogs
    humanfriendly
    property-manager
    fasteners
    six
  ];

  # ignore impure tests
  disabledTests = [
    "option"
    "retry"
    "remote"
    "ssh"
    "foreach"
    "local_context"
    "release" # meant to be ran on ubuntu to succeed
  ];

  pyproject = true;

  meta = {
    description = "Programmer friendly subprocess wrapper";
    homepage = "https://github.com/xolox/python-executor";
    changelog = "https://github.com/xolox/python-executor/blob/${finalAttrs.version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
    mainProgram = "executor";
  };
})
