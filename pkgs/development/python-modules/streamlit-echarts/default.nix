{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyecharts,
  setuptools,
  streamlit,
}:

buildPythonPackage rec {
  pname = "streamlit-echarts";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "andfanilo";
    repo = "streamlit-echarts";
    tag = "v${version}";
    hash = "sha256-VNliCZPkAYUx+TacBc6PrS4C4bjM5fmVx/Sj6aSw2Yc=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    pyecharts
    streamlit
  ];

  pyproject = true;
  pythonImportsCheck = [ "streamlit_echarts" ];

  meta = {
    description = "Streamlit component to render ECharts";
    homepage = "https://github.com/andfanilo/streamlit-echarts";
    changelog = "https://github.com/andfanilo/streamlit-echarts/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
