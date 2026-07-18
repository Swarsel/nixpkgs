{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pandas,
  setuptools,
  streamlit,
}:

buildPythonPackage rec {
  pname = "streamlit-kpi-card";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "pjoachims";
    repo = "streamlit-kpi-card";
    tag = version;
    hash = "sha256-w2hUEad6sMFq/KbYnNX7E/vOkIqsLwJZmzdgQTSVMm4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=45,<70" "setuptools"
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pandas
    streamlit
  ];

  pyproject = true;
  pythonImportsCheck = [ "streamlit_kpi_card" ];

  meta = {
    description = "KPI cards for Streamlit";
    homepage = "https://github.com/pjoachims/streamlit-kpi-card";
    changelog = "https://github.com/pjoachims/streamlit-kpi-card/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
