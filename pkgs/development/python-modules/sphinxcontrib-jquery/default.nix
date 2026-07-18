{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  fetchpatch,
  flit-core,
  pytestCheckHook,
  sphinx,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-jquery";
  version = "4.1";

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "jquery";
    tag = "v${version}";
    hash = "sha256-ZQGQcVmhWREFa2KyaOKdTz5W2AS2ur7pFp8qZ2IkxSE=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-dc9bhr/af3NmrIfoVabM1lNpXbGVsJoj7jq0E1BAtHw=";
      name = "fix-tests-with-sphinx7.1.patch";
      url = "https://github.com/sphinx-contrib/jquery/commit/ac97ce5202b05ddb6bf4e5b77151a8964b6bf632.patch";
    })
    (fetchpatch {
      hash = "sha256-pNeKE50sm4b/KhNDAEQ3oJYGV4I8CVHnbR76z0obT3E=";
      # https://github.com/sphinx-contrib/jquery/pull/28
      name = "fix-tests-with-sphinx7.2-and-python312.patch";
      url = "https://github.com/sphinx-contrib/jquery/commit/3318a82854fccec528cd73e12ab2ab96d8e71064.patch";
    })
  ];

  nativeBuildInputs = [ flit-core ];

  nativeCheckInputs = [
    defusedxml
    pytestCheckHook
  ];

  dependencies = [
    sphinx
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinxcontrib.jquery" ];
  pythonNamespaces = [ "sphinxcontrib" ];

  meta = {
    description = "Extension to include jQuery on newer Sphinx releases";

    longDescription = ''
      A sphinx extension that ensures that jQuery is installed for use
      in Sphinx themes or extensions
    '';

    homepage = "https://github.com/sphinx-contrib/jquery";
    changelog = "https://github.com/sphinx-contrib/jquery/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
