{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  ddt,
  hacking,
  installShellFiles,
  openstackdocstheme,
  osc-lib,
  osc-placement,
  pbr,
  python-aodhclient,
  python-barbicanclient,
  python-cinderclient,
  python-designateclient,
  python-heatclient,
  python-ironicclient,
  python-keystoneclient,
  python-magnumclient,
  python-manilaclient,
  python-mistralclient,
  python-neutronclient,
  python-octaviaclient,
  python-watcherclient,
  python-zaqarclient,
  python-zunclient,
  requests,
  requests-mock,
  setuptools,
  sphinxHook,
  sphinxcontrib-apidoc,
  stestrCheckHook,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-openstackclient";
  version = "10.0.0";

  src = fetchFromGitHub {
    owner = "openstack";
    repo = "python-openstackclient";
    tag = finalAttrs.version;
    hash = "sha256-UczEgOtZz4roIFg1R6RDGg0tiiiT6lAgJCdgpmK0960=";
  };

  patches = [
    ./fix-pyproject.patch
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  env.PBR_VERSION = finalAttrs.version;

  nativeCheckInputs = [
    ddt
    hacking
    requests-mock
    stestrCheckHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd openstack \
      --bash <($out/bin/openstack complete)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  build-system = [
    openstackdocstheme
    setuptools
    sphinxHook
    sphinxcontrib-apidoc
  ];

  dependencies = [
    osc-lib
    pbr
    python-cinderclient
    python-keystoneclient
    requests
  ]
  # to support proxy envs like ALL_PROXY in requests
  ++ requests.optional-dependencies.socks;

  optional-dependencies = {
    # See https://github.com/openstack/python-openstackclient/blob/master/doc/source/contributor/plugins.rst
    cli-plugins = [
      osc-placement
      python-aodhclient
      python-barbicanclient
      python-designateclient
      python-heatclient
      python-ironicclient
      python-magnumclient
      python-manilaclient
      python-mistralclient
      python-neutronclient
      python-octaviaclient
      python-watcherclient
      python-zaqarclient
      python-zunclient
    ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "openstackclient"
    "openstackclient.api"
    "openstackclient.common"
    "openstackclient.compute"
    "openstackclient.identity"
    "openstackclient.image"
    "openstackclient.network"
    "openstackclient.object"
    "openstackclient.volume"
    "openstackclient.tests"
  ];

  sphinxBuilders = [ "man" ];

  meta = {
    description = "OpenStack Command-line Client";
    homepage = "https://docs.openstack.org/python-openstackclient/latest/";
    license = lib.licenses.asl20;
    mainProgram = "openstack";
    downloadPage = "https://github.com/openstack/python-openstackclient/releases/tag/${finalAttrs.src.tag}";
    teams = [ lib.teams.openstack ];
  };
})
