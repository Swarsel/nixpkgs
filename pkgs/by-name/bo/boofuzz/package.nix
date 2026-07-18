{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "boofuzz";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "jtpereyda";
    repo = "boofuzz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ffZVFmfDAJ+Qn3hbeHY/CvYgpDLxB+jaYOiYyZqZ7mo=";
  };

  nativeCheckInputs = with python3.pkgs; [
    mock
    netifaces
    pytest-bdd
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    attrs
    click
    colorama
    flask
    funcy
    psutil
    pyserial
    pydot
    tornado
  ];

  disabledTests = [
    "TestNetworkMonitor"
    "TestNoResponseFailure"
    "TestProcessMonitor"
    "TestSocketConnection"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ "test_time_repeater" ];

  pyproject = true;
  pythonImportsCheck = [ "boofuzz" ];

  meta = {
    description = "Network protocol fuzzing tool";
    homepage = "https://github.com/jtpereyda/boofuzz";
    changelog = "https://github.com/jtpereyda/boofuzz/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "boo";
  };
})
