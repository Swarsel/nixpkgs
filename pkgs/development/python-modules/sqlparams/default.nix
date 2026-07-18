{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "sqlparams";
  version = "6.2.0";

  src = fetchFromGitHub {
    owner = "cpburnz";
    repo = "python-sql-parameters";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PcAv76ZtArJDbddziOMTiDmMXyDTieDpqMA92iG2vgA=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "sqlparams" ];

  meta = {
    description = "Convert DB API 2.0 named/numeric parameter styles to the style a driver supports";
    homepage = "https://github.com/cpburnz/python-sql-parameters";
    changelog = "https://github.com/cpburnz/python-sql-parameters/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ davidlghellin ];
  };
})
