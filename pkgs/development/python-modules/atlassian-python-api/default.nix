{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  deprecated,
  jmespath,
  lxml,
  oauthlib,
  pytestCheckHook,
  requests,
  requests-kerberos,
  requests-oauthlib,
  setuptools,
  six,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "atlassian-python-api";
  version = "4.0.7";

  src = fetchFromGitHub {
    owner = "atlassian-api";
    repo = "atlassian-python-api";
    tag = finalAttrs.version;
    hash = "sha256-8zfM/3apGMo6sTPA5ESu2SkgVOJUA09Wz/pGR12fA7c=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    deprecated
    jmespath
    lxml
    oauthlib
    requests
    requests-kerberos
    requests-oauthlib
    six
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "atlassian" ];

  meta = {
    description = "Python Atlassian REST API Wrapper";
    homepage = "https://github.com/atlassian-api/atlassian-python-api";
    changelog = "https://github.com/atlassian-api/atlassian-python-api/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
