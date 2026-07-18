{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "fritz-exporter";
  version = "2.6.2";

  src = fetchFromGitHub {
    owner = "pdreker";
    repo = "fritz_exporter";
    tag = "fritzexporter-v${finalAttrs.version}";
    hash = "sha256-qHx96TluE3RdkIfMcsnMt+LcHoqS2l5sD0+94yizbp8=";
  };

  postPatch = ''
    # don't test coverage
    sed -i "/^addopts/d" pyproject.toml
  '';

  nativeBuildInputs = with python3.pkgs; [
    poetry-core
  ];

  propagatedBuildInputs = with python3.pkgs; [
    attrs
    defusedxml
    fritzconnection
    prometheus-client
    pyyaml
    requests
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  # Required for tests
  __darwinAllowLocalNetworking = true;
  pyproject = true;

  pythonRelaxDeps = [
    "defusedxml"
    "attrs"
  ];

  meta = {
    description = "Prometheus exporter for Fritz!Box home routers";
    homepage = "https://github.com/pdreker/fritz_exporter";
    changelog = "https://github.com/pdreker/fritz_exporter/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ marie ];
    mainProgram = "fritzexporter";
  };
})
