{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  parver,
  pulumi,
  semver,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pulumi-aws";
  # Version is independent of pulumi's.
  version = "7.24.0";

  src = fetchFromGitHub {
    owner = "pulumi";
    repo = "pulumi-aws";
    tag = "v${version}";
    hash = "sha256-PADClQ8ct9w0igKxQNoW4Act0n0vx1HiD7ysH4PwgFU=";
  };

  postPatch = ''
    # We need the version of pulumi-aws in its package metadata to be accurate
    # as this seems to be used to determine which version of the
    # pulumi-resource-aws plugin to be dynamically downloaded by the pulumi CLI
    substituteInPlace pyproject.toml \
      --replace-fail "7.0.0a0+dev" "${version}"
  '';

  # Checks require cloud resources
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    parver
    pulumi
    semver
  ];

  pyproject = true;
  pythonImportsCheck = [ "pulumi_aws" ];
  sourceRoot = "${src.name}/sdk/python";

  meta = {
    description = "Pulumi python amazon web services provider";
    homepage = "https://github.com/pulumi/pulumi-aws";
    changelog = "https://github.com/pulumi/pulumi-aws/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
