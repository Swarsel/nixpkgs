{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  portpicker,
  # tests
  procps,
  pyserial,
  pytestCheckHook,
  pytz,
  pyyaml,
  # build-system
  setuptools,
  timeout-decorator,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "mobly";
  version = "1.13";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mobly";
    tag = version;
    hash = "sha256-lQyhLZFA9lad7LYKa6AP+nQonTRtiFA8Egjo0ATbLVI=";
  };

  nativeCheckInputs = [
    procps
    pytestCheckHook
    pytz
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  dependencies = [
    portpicker
    pyserial
    pyyaml
    timeout-decorator
    typing-extensions
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # cannot access /usr/bin/pgrep from the sandbox
    "test_stop_standing_subproc"
    "test_stop_standing_subproc_and_descendants"
    "test_stop_standing_subproc_without_pipe"
  ];

  pyproject = true;

  meta = {
    description = "Automation framework for special end-to-end test cases";
    homepage = "https://github.com/google/mobly";
    changelog = "https://github.com/google/mobly/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
