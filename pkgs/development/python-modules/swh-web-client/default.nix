{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  click,
  dateutils,
  pytest-mock,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
  swh-auth,
  swh-core,
  swh-model,
  types-python-dateutil,
  types-pyyaml,
  types-requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "swh-web-client";
  version = "0.9.2";

  src = fetchFromGitLab {
    owner = "devel";
    repo = "swh-web-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZZptYLC1os2i0NtBD3mp4QaQQRoKxnr9k8gJuqmpizE=";
    domain = "gitlab.softwareheritage.org";
    group = "swh";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-mock
    requests-mock
    types-python-dateutil
    types-pyyaml
    types-requests
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    click
    dateutils
    requests
    swh-auth
    swh-core
    swh-model
  ];

  pyproject = true;
  pythonImportsCheck = [ "swh.web.client" ];

  pythonRelaxDeps = [
    # we patched click 8.2.1
    "click"
  ];

  meta = {
    description = "Client for Software Heritage Web applications, via their APIs";
    homepage = "https://gitlab.softwareheritage.org/swh/devel/swh-web-client";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
