{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
}:

buildPythonPackage (finalAttrs: {
  pname = "bhopengraph";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "p0dalirius";
    repo = "bhopengraph";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pT+xdcxFLQUrXpZxS0gmXjyhtR1jqDsBAPHgEhxX2R8=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "bhopengraph" ];

  meta = {
    description = "Library to create BloodHound OpenGraphs";
    homepage = "https://github.com/p0dalirius/bhopengraph";
    changelog = "https://github.com/p0dalirius/bhopengraph/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
