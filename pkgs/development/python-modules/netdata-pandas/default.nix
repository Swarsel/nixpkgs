{
  lib,
  fetchFromGitHub,
  asks,
  buildPythonPackage,
  pandas,
  requests,
  setuptools,
  trio,
}:

buildPythonPackage rec {
  pname = "netdata-pandas";
  version = "0.0.41";

  src = fetchFromGitHub {
    owner = "netdata";
    repo = "netdata-pandas";
    rev = "v${version}";
    hash = "sha256-AXt8BKWyM3glm5hrRryb+vBzs3z2x61HhbR6DDZkh9o=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    pandas
    requests
    trio
    asks
  ];

  pyproject = true;
  pythonImportsCheck = [ "netdata_pandas" ];

  meta = {
    description = "Library to pull data from the netdata REST API into a pandas dataframe";
    homepage = "https://github.com/netdata/netdata-pandas";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
