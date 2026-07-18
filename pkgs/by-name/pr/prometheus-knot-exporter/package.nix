{
  lib,
  fetchPypi,
  nixosTests,
  python3,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "knot-exporter";
  version = "3.5.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-4V7fIY5qgKFGSKoodRFgP8e0P0DDvsBPBmzP9TdG98A=";
    pname = "knot_exporter";
  };

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    libknot
    prometheus-client
    psutil
  ];

  pyproject = true;

  pythonImportsCheck = [
    "knot_exporter"
  ];

  passthru.tests = { inherit (nixosTests.prometheus-exporters) knot; };

  meta = {
    description = "Prometheus exporter for Knot DNS";
    homepage = "https://gitlab.nic.cz/knot/knot-dns/-/tree/master/python/knot_exporter";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      ma27
      hexa
    ];

    mainProgram = "knot-exporter";
  };
}
