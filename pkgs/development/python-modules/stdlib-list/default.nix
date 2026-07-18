{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
}:

buildPythonPackage rec {
  pname = "stdlib-list";
  version = "0.12.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-UXgk8n7onlkdiufB3Z/zT2curlDuiG6jG7iBbXdTVnU=";
    pname = "stdlib_list";
  };

  # tests see mismatches to our standard library
  doCheck = false;
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "stdlib_list" ];

  meta = {
    description = "List of Python Standard Libraries";
    homepage = "https://github.com/jackmaney/python-stdlib-list";
    changelog = "https://github.com/pypi/stdlib-list/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
