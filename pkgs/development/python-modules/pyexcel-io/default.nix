{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyexcel-io";
  version = "0.6.7.1";

  src = fetchFromGitHub {
    owner = "pyexcel";
    repo = "pyexcel-io";
    tag = "v${version}";
    hash = "sha256-DBiHHiKXR26/WPJDmEZpRgjvJitFaidbV41Tvn0etLY=";
  };

  # Tests depend on stuff that depends on this.
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ lml ];
  pyproject = true;
  pythonImportsCheck = [ "pyexcel_io" ];

  meta = {
    description = "One interface to read and write the data in various excel formats, import the data into and export the data from databases";
    homepage = "http://docs.pyexcel.org/";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
