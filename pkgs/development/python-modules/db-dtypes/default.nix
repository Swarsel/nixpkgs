{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  numpy,
  packaging,
  pandas,
  pyarrow,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "db-dtypes";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "googleapis";
    repo = "google-cloud-python";
    tag = "db-dtypes-v${finalAttrs.version}";
    hash = "sha256-KJviH4dofYSvZu9S7VMBSnGjH66xMUEvhcmZN7GJ4Iw=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-0NvbTCnr95IW7rkQVu3iUDsNXU/LzXhJwwSDdliFZ+Y=";
      name = "support-pandas-3.0.patch";
      relative = "packages/db-dtypes";
      url = "https://github.com/googleapis/google-cloud-python/commit/2086b34d8b3418462c9bc89b96eac779a25a3afd.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    packaging
    pandas
    pyarrow
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "db_dtypes" ];
  sourceRoot = "${finalAttrs.src.name}/packages/db-dtypes";

  meta = {
    description = "Pandas Data Types for SQL systems (BigQuery, Spanner)";
    homepage = "https://github.com/googleapis/google-cloud-python/tree/main/packages/db-dtypes";
    changelog = "https://github.com/googleapis/google-cloud-python/blob/${finalAttrs.src.tag}/packages/db-dtypes/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
