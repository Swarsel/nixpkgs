{
  lib,
  fetchFromGitHub,
  backports-zstd,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  pytestCheckHook,
  pythonOlder,
  typing-extensions,
  zstd-c,
}:

buildPythonPackage rec {
  pname = "pyzstd";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "Rogdham";
    repo = "pyzstd";
    tag = version;
    hash = "sha256-1oUqnZCBJYu8haFIQ+T2KaSQaa1xnZyJHLzOQg4Fdw8=";
  };

  postPatch = ''
    # pyzst needs a copy of upstream zstd's license
    ln -s ${zstd-c.src}/LICENSE zstd
  '';

  buildInputs = [
    zstd-c
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    backports-zstd
  ]
  ++ lib.optionals (pythonOlder "3.13") [
    typing-extensions
  ];

  pypaBuildFlags = [
    "--config-setting=--global-option=--dynamic-link-zstd"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pyzstd"
  ];

  pythonRelaxDeps = [
    "typing-extensions"
  ];

  meta = {
    description = "Python bindings to Zstandard (zstd) compression library";
    homepage = "https://pyzstd.readthedocs.io";
    changelog = "https://github.com/Rogdham/pyzstd/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      MattSturgeon
      pitkling
      PopeRigby
    ];
  };
}
