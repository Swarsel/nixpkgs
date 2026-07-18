{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  boto3,
  buildPythonPackage,
  ftfy,
  mailchecker,
  openpyxl,
  orjson,
  phonenumbers,
  pydantic,
  pytestCheckHook,
  python-dateutil,
  python-decouple,
  python-fsutil,
  python-slugify,
  pyyaml,
  requests,
  setuptools,
  tomli-w,
  useful-types,
  xlrd,
  xmltodict,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-benedict";
  version = "0.38.0";

  src = fetchFromGitHub {
    owner = "fabiocaccamo";
    repo = "python-benedict";
    tag = finalAttrs.version;
    hash = "sha256-1YZqc0Ytqx4a1WGaqz5y0r2hw3okvax0/r267YTTGCE=";
  };

  nativeCheckInputs = [
    orjson
    pytestCheckHook
    python-decouple
  ]
  ++ lib.flatten (builtins.attrValues finalAttrs.passthru.optional-dependencies);

  build-system = [ setuptools ];

  dependencies = [
    python-fsutil
    python-slugify
    requests
    useful-types
  ];

  disabledTests = [
    # Tests require network access
    "test_from_base64_with_valid_url_valid_content"
    "test_from_html_with_valid_file_valid_content"
    "test_from_html_with_valid_url_valid_content"
    "test_from_json_with_valid_url_valid_content"
    "test_from_pickle_with_valid_url_valid_content"
    "test_from_plist_with_valid_url_valid_content"
    "test_from_query_string_with_valid_url_valid_content"
    "test_from_toml_with_valid_url_valid_content"
    "test_from_xls_with_valid_url_valid_content"
    "test_from_xml_with_valid_url_valid_content"
    "test_from_yaml_with_valid_url_valid_content"
  ];

  optional-dependencies = {
    all = [
      beautifulsoup4
      boto3
      ftfy
      mailchecker
      openpyxl
      phonenumbers
      pydantic
      python-dateutil
      pyyaml
      tomli-w
      xlrd
      xmltodict
    ];

    html = [
      beautifulsoup4
      xmltodict
    ];

    io = [
      beautifulsoup4
      openpyxl
      pyyaml
      tomli-w
      xlrd
      xmltodict
    ];

    parse = [
      ftfy
      mailchecker
      phonenumbers
      python-dateutil
    ];

    s3 = [ boto3 ];
    schema = [ pydantic ];
    toml = [ tomli-w ];

    xls = [
      openpyxl
      xlrd
    ];

    xml = [ xmltodict ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "benedict" ];
  pythonRelaxDeps = [ "boto3" ];

  meta = {
    description = "Module with keylist/keypath support";
    homepage = "https://github.com/fabiocaccamo/python-benedict";
    changelog = "https://github.com/fabiocaccamo/python-benedict/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
