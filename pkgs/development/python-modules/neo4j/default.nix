{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pandas,
  pyarrow,
  pytz,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "neo4j";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "neo4j";
    repo = "neo4j-python-driver";
    tag = finalAttrs.version;
    hash = "sha256-M1bBZJOo4GS71Gt4vfRYfLduh/X8XFABgycQNVPsWSs=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools == 82.0.1" "setuptools" \
      --replace-fail 'dynamic = ["version"]' 'version = "${finalAttrs.version}"'
  '';

  # Missing dependencies
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pytz ];

  optional-dependencies = {
    numpy = [ numpy ];

    pandas = [
      numpy
      pandas
    ];

    pyarrow = [ pyarrow ];
  };

  pyproject = true;
  pythonImportsCheck = [ "neo4j" ];

  meta = {
    description = "Neo4j Bolt Driver for Python";
    homepage = "https://github.com/neo4j/neo4j-python-driver";
    changelog = "https://github.com/neo4j/neo4j-python-driver/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
