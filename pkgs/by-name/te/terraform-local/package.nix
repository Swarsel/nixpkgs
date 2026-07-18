{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "terraform_local";
  version = "0.25.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-hzDPyS3Nv8sQKTQgyvsiVm1Woq9YE56Kl2gosQ4Hx+I=";
  };

  # Can’t run `pytestCheckHook` because the tests are integration tests and expect localstack to be present, which in turn expects docker to be running.
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    python-hcl2
    packaging
    localstack-client
  ];

  # There is no `pythonImportsCheck` because the package only outputs a binary: tflocal
  dontUsePythonImportsCheck = true;
  pyproject = true;

  meta = {
    description = "Terraform CLI wrapper to deploy your Terraform applications directly to LocalStack";
    homepage = "https://github.com/localstack/terraform-local";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ shivaraj-bh ];
  };
})
