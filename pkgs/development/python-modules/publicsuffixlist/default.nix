{
  lib,
  buildPythonPackage,
  fetchPypi,
  pandoc,
  publicsuffix-list,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "publicsuffixlist";
  version = "1.0.2.20260710";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-lCJ66oP52KxMfVJ/LIan0qx2tjn09RAD0J9+8foEI6Q=";
  };

  postPatch = ''
    rm publicsuffixlist/public_suffix_list.dat
    ln -s ${publicsuffix-list}/share/publicsuffix/public_suffix_list.dat publicsuffixlist/public_suffix_list.dat
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  enabledTestPaths = [ "publicsuffixlist/test.py" ];

  optional-dependencies = {
    readme = [ pandoc ];
    update = [ requests ];
  };

  pyproject = true;
  pythonImportsCheck = [ "publicsuffixlist" ];

  meta = {
    description = "Public Suffix List parser implementation";
    homepage = "https://github.com/ko-zu/psl";
    changelog = "https://github.com/ko-zu/psl/blob/v${finalAttrs.version}-gha/CHANGES.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "publicsuffixlist-download";
  };
})
