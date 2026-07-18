{
  lib,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "kea-exporter";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "mweinelt";
    repo = "kea-exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UwQYR01cBdPEUBhOo5TqwmptAvJpxln1OLU2boAFdn4=";
  };

  nativeBuildInputs = with python3Packages; [
    pdm-backend
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    prometheus-client
    requests
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  pyproject = true;

  passthru.tests = {
    inherit (nixosTests) kea;
  };

  meta = {
    description = "Export Kea Metrics in the Prometheus Exposition Format";
    homepage = "https://github.com/mweinelt/kea-exporter";
    changelog = "https://github.com/mweinelt/kea-exporter/blob/v${finalAttrs.version}/HISTORY";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "kea-exporter";
  };
})
