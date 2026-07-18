{
  lib,
  fetchFromGitHub,
  absl-py,
  buildPythonPackage,
  future,
  mock,
  mpyq,
  numpy,
  portpicker,
  protobuf,
  pygame,
  s2clientprotocol,
  sc2-headless,
  six,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "pysc2";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "deepmind";
    repo = "pysc2";
    tag = "v${version}";
    sha256 = "sha256-70Uqs30Dyq1u+e1CTR8mO/rzZangBvgY0ah2l7VJLhQ=";
  };

  patches = [
    ./fix-setup-for-py3.patch
    ./parameterize-runconfig-sc2path.patch
  ];

  postPatch = ''
    substituteInPlace "./pysc2/run_configs/platforms.py" \
      --subst-var-by 'sc2path' '${sc2-headless}'
  '';

  propagatedBuildInputs = [
    absl-py
    future
    mock
    mpyq
    numpy
    portpicker
    protobuf
    pygame
    s2clientprotocol
    six
    websocket-client
    sc2-headless
  ];

  format = "setuptools";

  meta = {
    description = "Starcraft II environment and library for training agents";
    homepage = "https://github.com/deepmind/pysc2";
    changelog = "https://github.com/google-deepmind/pysc2/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
