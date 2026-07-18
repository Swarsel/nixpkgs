{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional dependencies
  pandas,
  # test dependencies
  pycurl,
  pytestCheckHook,
  # required dependencies
  requests,
  setuptools,
  sqlalchemy,
  tornado,
}:

buildPythonPackage rec {
  pname = "pydruid";
  version = "0.6.8";

  src = fetchFromGitHub {
    owner = "druid-io";
    repo = "pydruid";
    tag = version;
    hash = "sha256-em4UuNnGdfT6KC9XiWSkCmm4DxdvDS+DGY9kw25iepo=";
  };

  # patch out the CLI because it doesn't work with newer versions of pygments
  postPatch = ''
    substituteInPlace setup.py --replace-fail '"console_scripts": ["pydruid = pydruid.console:main"],' ""
  '';

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytestCheckHook
    pycurl
  ]
  ++ lib.concatAttrValues optional-dependencies;

  format = "setuptools";

  optional-dependencies = {
    async = [ tornado ];
    pandas = [ pandas ];
    sqlalchemy = [ sqlalchemy ];
    # druid has a `cli` extra, but it doesn't work with nixpkgs pygments
  };

  pythonImportsCheck = [ "pydruid" ];

  meta = {
    description = "Simple API to create, execute, and analyze Druid queries";
    homepage = "https://github.com/druid-io/pydruid";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
