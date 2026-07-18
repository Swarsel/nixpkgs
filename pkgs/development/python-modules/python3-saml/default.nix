{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  freezegun,
  isodate,
  lxml,
  poetry-core,
  pytestCheckHook,
  xmlsec,
}:

buildPythonPackage (finalAttrs: {
  pname = "python3-saml";
  version = "1.16.0";

  src = fetchFromGitHub {
    owner = "onelogin";
    repo = "python3-saml";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KyDGmqhg/c29FaXPKK8rWKSBP6BOCpKKpOujCavXUcc=";
  };

  patches = [
    # Fix build system, https://github.com/SAML-Toolkits/python3-saml/pull/341
    (fetchpatch {
      hash = "sha256-MvX1LXhf3LJUy3O7L0/ySyVY4KDGc/GKJud4pOkwVIk=";
      name = "switch-to-poetry-core.patch";
      url = "https://github.com/SAML-Toolkits/python3-saml/commit/231a7e19543138fdd7424c01435dfe3f82bbe9ce.patch";
    })
  ];

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    isodate
    lxml
    xmlsec
  ];

  nativeCheckInputs = [
    freezegun
    pytestCheckHook
  ];

  disabledTests = [
    # Tests require network access or additions files
    "OneLogin_Saml2_Metadata_Test"
    "OneLogin_Saml2_Response_Test"
    "OneLogin_Saml2_Utils_Test"
    "OneLogin_Saml2_Settings_Test"
    "OneLogin_Saml2_Auth_Test"
    "OneLogin_Saml2_Authn_Request_Test"
    "OneLogin_Saml2_IdPMetadataParser_Test"
    "OneLogin_Saml2_Logout_Request_Test"
  ];

  pyproject = true;
  pythonImportsCheck = [ "onelogin.saml2" ];

  meta = {
    description = "OneLogin's SAML Python Toolkit";
    homepage = "https://github.com/onelogin/python3-saml";
    changelog = "https://github.com/SAML-Toolkits/python3-saml/blob/v${finalAttrs.version}/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zhaofengli ];
  };
})
