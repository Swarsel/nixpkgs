{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "language-tags";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "OnroerendErfgoed";
    repo = "language-tags";
    tag = finalAttrs.version;
    hash = "sha256-T9K290seKhQLqW36EfA9kn3WveKCmyjN4Mx2j50qIEk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "language_tags" ];

  meta = {
    description = "Dealing with IANA language tags in Python";
    homepage = "https://language-tags.readthedocs.io/en/latest/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
