{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  marshmallow,
  mock,
  openapi-spec-validator,
  packaging,
  prance,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "apispec";
  version = "6.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CoiFVc1KpftxdgQb4VaEFU/YlhBV4WcucDq/c36HYb8=";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ flit-core ];
  dependencies = [ packaging ];

  optional-dependencies = {
    marshmallow = [ marshmallow ];

    validation = [
      openapi-spec-validator
      prance
    ]
    ++ prance.optional-dependencies.osv;

    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "apispec" ];

  meta = {
    description = "Pluggable API specification generator with support for the OpenAPI Specification";
    homepage = "https://github.com/marshmallow-code/apispec";
    changelog = "https://github.com/marshmallow-code/apispec/blob/${version}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
