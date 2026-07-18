{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  faker,
  # dependencies
  ghome-foyer-api,
  gpsoauth,
  grpcio,
  hatch-vcs,
  # build system
  hatchling,
  # test dependencies
  pytestCheckHook,
  requests,
  simplejson,
  zeroconf,
}:

buildPythonPackage rec {
  pname = "glocaltokens";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "leikoilja";
    repo = "glocaltokens";
    tag = "v${version}";
    hash = "sha256-+7HpyZUumu1r/UXM4awckjTkpVbCz7MsAJOp2JiJzho=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    faker
  ];

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    ghome-foyer-api
    gpsoauth
    grpcio
    requests
    simplejson
    zeroconf
  ];

  pyproject = true;

  pythonImportsCheck = [
    "glocaltokens"
    "glocaltokens.client"
    "glocaltokens.scanner"
  ];

  meta = {
    description = "Library to extract google home devices local authentication tokens from google servers";
    homepage = "https://github.com/leikoilja/glocaltokens";
    changelog = "https://github.com/leikoilja/glocaltokens/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hensoko
    ];
  };
}
