{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "savepagenow";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "pastpages";
    repo = "savepagenow";
    tag = finalAttrs.version;
    sha256 = "sha256-ztM1g71g8SN1LTyFF7sxaLhC3+nVsC9fJwfYPjkUsdE=";
  };

  # requires network access
  doCheck = false;
  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    click
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "savepagenow" ];

  meta = {
    description = "Simple Python wrapper for archive.org's \"Save Page Now\" capturing service";
    homepage = "https://github.com/pastpages/savepagenow";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "savepagenow";
  };
})
