{
  lib,
  fetchPypi,
  latexminted,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "latexminted";
  version = "0.7.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-1yQJbzRg8iD9vq4gfVqyvA4041lJfzPfmBT4uwJGQPo=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pygments
    latex2pydata
    latexrestricted
  ];

  pyproject = true;

  passthru = {
    tests.version = testers.testVersion { package = latexminted; };
  };

  meta = {
    description = "Python executable for LaTeX minted package";
    homepage = "https://pypi.org/project/latexminted";
    license = lib.licenses.lppl13c;
    maintainers = with lib.maintainers; [ romildo ];
    mainProgram = "latexminted";
  };
})
