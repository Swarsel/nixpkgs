{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "aws-sso-util";
  version = "4.33.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-5I1/WRFENFDSjhrBYT+BuaoVursbIFW0Ux34fbQ6Cd8=";
    pname = "aws_sso_util";
  };

  build-system = [
    python3Packages.poetry-core
  ];

  dependencies = with python3Packages; [
    aws-error-utils
    aws-sso-lib
    boto3
    click
    jsonschema
    python-dateutil
    pyyaml
    requests
  ];

  pyproject = true;

  meta = {
    description = "Utilities to make AWS SSO easier";
    homepage = "https://pypi.org/project/aws-sso-util/";
    changelog = "https://github.com/benkehoe/aws-sso-util/releases";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cterence ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "aws-sso-util";
    downloadPage = "https://pypi.org/project/aws-sso-util/#files";
  };
})
