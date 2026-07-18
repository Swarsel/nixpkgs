{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hacking,
  installShellFiles,
  keystoneauth1,
  openstackdocstheme,
  openstacksdk,
  pbr,
  # direct
  python-keystoneclient,
  setuptools,
  # docs
  sphinxHook,
  sphinxcontrib-apidoc,
  stestr,
  # tests
  stestrCheckHook,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-swiftclient";
  version = "4.10.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-swiftclient";
    tag = finalAttrs.version;
    hash = "sha256-G3o9R3+hDQgvSnmle0paZo/KV56OMU38tIXqUJGmUaQ=";
  };

  nativeBuildInputs = [
    openstackdocstheme
    sphinxcontrib-apidoc
    sphinxHook
    installShellFiles
  ];

  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    stestrCheckHook
    openstacksdk
    hacking
    keystoneauth1
    stestr
    openstacksdk
  ];

  postInstall = ''
    installShellCompletion --cmd swift --bash tools/swift.bash_completion
    installManPage doc/manpages/*
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = [
    pbr
    setuptools
  ];

  dependencies = [
    python-keystoneclient
  ];

  pyproject = true;

  pythonImportsCheck = [
    "swiftclient"
  ];

  sphinxBuilders = [ "man" ];

  meta = {
    description = "Client library for OpenStack Swift API";
    homepage = "https://docs.openstack.org/python-swiftclient/latest/";
    license = lib.licenses.asl20;
    mainProgram = "swift";
    downloadPage = "https://github.com/openstack/python-swiftclient/releases/tag/${finalAttrs.src.tag}";
    teams = [ lib.teams.openstack ];
  };
})
