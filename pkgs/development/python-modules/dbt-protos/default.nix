{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  protobuf,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dbt-protos";
  version = "1.0.455";

  src = fetchFromGitHub {
    owner = "dbt-labs";
    repo = "proto-python-public";
    tag = "v${version}";
    hash = "sha256-o0H5sGXVxiZgc9Vdwgd5IUlzqHRqSuYbkwI/R9M8uY8=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    protobuf
  ];

  pyproject = true;

  pythonImportsCheck = [
    "dbtlabs.proto.public.v1"
  ];

  meta = {
    description = "dbt public protos";
    homepage = "https://github.com/dbt-labs/proto-python-public";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
