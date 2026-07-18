{
  lib,
  fetchFromGitHub,
  # glue
  boto3,
  botocore,
  buildPythonPackage,
  # build-system
  hatchling,
  # hive2
  hive-metastore-client,
  lance-namespace,
  # dependencies
  lance-namespace-urllib3-client,
  # optional-dependencies
  # dir
  opendal,
  pyarrow,
  # tests
  pylance,
  pytestCheckHook,
  thrift,
  # pylance,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "lance-namespace";
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "lancedb";
    repo = "lance-namespace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QYzVsarjTg2arNNuCFbVgtA7rfLTm6AJD3liNr3QuSU=";
  };

  # Tests require pylance, which is a circular dependency
  doCheck = false;

  nativeCheckInputs = [
    pylance
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.optional-dependencies;

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    lance-namespace-urllib3-client
    typing-extensions
    # pylance
    pyarrow
  ];

  optional-dependencies = {
    dir = [ opendal ];

    glue = [
      boto3
      botocore
    ];

    hive2 = [
      hive-metastore-client
      thrift
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lance_namespace" ];
  sourceRoot = "${finalAttrs.src.name}/python/lance_namespace";

  passthru.tests.pytest = lance-namespace.overridePythonAttrs {
    doCheck = true;

    disabledTests = [
      # AttributeError: 'function' object has no attribute 'write_dataset'
      "test_create_table"
      "test_describe_table"
      "test_drop_table"
      "test_list_tables"

      # RuntimeError: Failed to list tables: Operator.list() got an unexpected keyword argument 'recursive'
      "test_create_empty_table"
      "test_empty_list_tables"

      # lance_namespace.unity.LanceNamespaceException: Failed to drop namespace: BehaviorEnum
      "test_drop_namespace"

      # pydantic_core._pydantic_core.ValidationError: 1 validation error for ListNamespacesResponse namespaces
      "test_list_namespaces_schemas"
      "test_list_namespaces_top_level"
    ];
  };

  meta = {
    description = "Open specification on top of the storage-based Lance table and file format to standardize access to a collection of Lance tables";
    homepage = "https://github.com/lancedb/lance-namespace/tree/main/python/lance_namespace";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
