{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "repocheck";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "kynikos";
    repo = "repocheck";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pCz+oAfDFyDeuXumfNzLTXnftM9+IG+lZzWSKtbZ9dg=";
  };

  # no tests
  doCheck = false;
  build-system = [ python3Packages.setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "repocheck" ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Check the status of code repositories under a root directory";
    license = lib.licenses.gpl3Plus;
    mainProgram = "repocheck";
  };
})
