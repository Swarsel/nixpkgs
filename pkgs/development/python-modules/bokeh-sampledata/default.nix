{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  icalendar,
  pandas,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "bokeh-sampledata";
  version = "2025.0";

  src = fetchFromGitHub {
    owner = "bokeh";
    repo = "bokeh_sampledata";
    tag = version;
    hash = "sha256-gAiiNm9t+4z0aFO6pr8FfYGF04pO7u6Wjsbou+I2blk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools-git-versioning"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    icalendar
    pandas
  ];

  pyproject = true;

  pythonImportsCheck = [
    "bokeh_sampledata"
  ];

  meta = {
    description = "Sample datasets for Bokeh examples";
    homepage = "https://pypi.org/project/bokeh-sampledata";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
