{
  lib,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  hatchling,
  replaceVars,
}:

buildPythonPackage rec {
  pname = "attrs";
  version = "26.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0DzricsyKo/XBtT7kZQHN7ZkKqNpmP4TCpvJbJhe/zI=";
  };

  outputs = [
    "out"
    "testout"
  ];

  patches = [
    (replaceVars ./remove-hatch-plugins.patch {
      # hatch-vcs and hatch-fancy-pypi-readme depend on pytest, which depends on attrs
      inherit version;
    })
  ];

  nativeBuildInputs = [ hatchling ];
  # pytest depends on attrs, so we can't do this out-of-the-box.
  # Instead, we do this as a passthru.tests test.
  doCheck = false;

  postInstall = ''
    # Install tests as the tests output.
    mkdir $testout
    cp -R tests $testout
  '';

  pyproject = true;
  pythonImportsCheck = [ "attr" ];

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Python attributes without boilerplate";
    homepage = "https://github.com/python-attrs/attrs";
    changelog = "https://github.com/python-attrs/attrs/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
  };
}
