{
  aiohomematic,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  inherit (aiohomematic) version src;
  pname = "aiohomematic-test-support";

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "aiohomematic_test_support" ];
  sourceRoot = "${src.name}/aiohomematic_test_support";

  meta = {
    inherit (aiohomematic.meta) license maintainers;
    description = "Support-only package for AioHomematic (tests/dev)";
    homepage = "https://github.com/SukramJ/aiohomematic/tree/devel/aiohomematic_test_support";
  };
}
