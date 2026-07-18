{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "s3bro";
  version = "2.8";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-+OqcLbXilbY4h/zRAkvRd8taVIOPyiScOAcDyPZ4RUw=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "use_2to3=True," ""
  '';

  # No tests
  doCheck = false;
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    boto3
    botocore
    click
    termcolor
  ];

  pyproject = true;

  pythonImportsCheck = [
    "s3bro"
  ];

  meta = {
    description = "S3 CLI tool";
    homepage = "https://github.com/rsavordelli/s3bro";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
    mainProgram = "s3bro";
  };
})
