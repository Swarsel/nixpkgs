{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  matplotlib,
  pandas,
  # build-system
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "tt-perf-report";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-perf-report";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cSlQ9Byv9LzKc4gS3QLeq3bHdmIVpl8AeK3Gh0mNDAQ=";
  };

  __structuredAttrs = true;

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    matplotlib
    pandas
  ];

  pyproject = true;
  pythonImportsCheck = [ "tt_perf_report" ];
  pythonRelaxDeps = [ "matplotlib" ];

  meta = {
    description = "Tool for analyzing performance traces from Metal operations";
    homepage = "https://github.com/tenstorrent/tt-perf-report";
    changelog = "https://github.com/tenstorrent/tt-perf-report/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mert-kurttutan ];
    mainProgram = "tt-perf-report";
  };
})
