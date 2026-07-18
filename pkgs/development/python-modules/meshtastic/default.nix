{
  lib,
  fetchFromGitHub,
  argcomplete,
  bleak,
  buildPythonPackage,
  dash,
  dash-bootstrap-components,
  dotmap,
  hypothesis,
  packaging,
  pandas,
  pandas-stubs,
  parse,
  platformdirs,
  poetry-core,
  ppk2-api,
  print-color,
  protobuf,
  pyarrow,
  pypubsub,
  pyqrcode,
  pyserial,
  pytap2,
  pytestCheckHook,
  pyyaml,
  requests,
  riden,
  setuptools,
  tabulate,
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "meshtastic";
  version = "2.7.10";

  src = fetchFromGitHub {
    owner = "meshtastic";
    repo = "python";
    tag = finalAttrs.version;
    hash = "sha256-bzDGiwaq58zmp93HXK9dpMVQiVZJA8MRO63bm3SPDzU=";
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  preCheck = ''
    export PATH="$PATH:$out/bin";
  '';

  build-system = [ poetry-core ];

  dependencies = [
    bleak
    packaging
    protobuf
    pypubsub
    pyserial
    pyyaml
    requests
    setuptools
    tabulate
  ];

  disabledTestPaths = [
    # Circular import with dash-bootstrap-components
    "meshtastic/tests/test_analysis.py"
  ];

  disabledTests = [
    # TypeError
    "test_main_info_with_seriallog_output_txt"
    "test_main_info_with_seriallog_stdout"
    "test_main_info_with_tcp_interfa"
    "test_main_info"
    "test_main_no_proto"
    "test_main_support"
    "test_MeshInterface"
    "test_message_to_json_shows_all"
    "test_node"
    "test_SerialInterface_single_port"
    "test_support_info"
    "test_TCPInterface"
  ];

  optional-dependencies = {
    analysis = [
      dash
      dash-bootstrap-components
      pandas
      pandas-stubs
    ];

    cli = [
      argcomplete
      dotmap
      print-color
      pyqrcode
      wcwidth
    ];

    powermon = [
      parse
      platformdirs
      ppk2-api
      pyarrow
      riden
    ];

    tunnel = [ pytap2 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "meshtastic" ];

  pythonRelaxDeps = [
    "bleak"
    "packaging"
    "protobuf"
    "tabulate"
  ];

  meta = {
    description = "Python API for talking to Meshtastic devices";
    homepage = "https://github.com/meshtastic/python";
    changelog = "https://github.com/meshtastic/python/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
