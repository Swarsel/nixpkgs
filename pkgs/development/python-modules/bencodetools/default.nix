{
  bencodetools,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage {
  inherit (bencodetools) pname version src;
  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  dontConfigure = true;
  pyproject = true;

  pythonImportsCheck = [
    "bencode"
    "typevalidator"
  ];

  meta = {
    inherit (bencodetools.meta)
      description
      homepage
      license
      maintainers
      ;
  };
}
