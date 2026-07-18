{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "boa-api";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "boalang";
    repo = "api-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8tt68NLi5ewSKiHdu3gDawTBPylbDmB4zlUUqa7EQuY=";
  };

  # upstream has no tests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "boaapi" ];

  meta = {
    description = "Python client API for communicating with Boa's (https://boa.cs.iastate.edu/) XML-RPC based services";
    homepage = "https://github.com/boalang/api-python";
    changelog = "https://github.com/boalang/api-python/blob/${finalAttrs.src.rev}/Changes.txt";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ swflint ];
  };
})
