{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  datasets,
  huggingface-hub,
  numpy,
  # optional-dependencies
  optimum-onnx,
  packaging,
  # build-system
  setuptools,
  torch,
  transformers,
}:

buildPythonPackage rec {
  pname = "optimum";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "huggingface";
    repo = "optimum";
    tag = "v${version}";
    hash = "sha256-nA73afFr9wqJWmobBw5hOIjRvQ6I8QvVZoRJnYnXzUc=";
  };

  # almost all tests try to connect to https://huggingface.co
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    huggingface-hub
    numpy
    packaging
    torch
    transformers
  ];

  optional-dependencies = {
    furiosa = [
      # optimum-furiosa
    ];

    graphcore = [
      # optimum-graphcore
    ];

    habana = [
      # optimum-habana
    ];

    intel = [
      # optimum-intel
    ];

    neural-compressor = [
      # optimum-intel
    ]; # ++ optimum-intel.optional-dependencies.neural-compressor;

    neuron = [
      # optimum-neuron
    ]; # ++ optimum-neuron.optional-dependencies.neuron;

    neuronx = [
      # optimum-neuron
    ]; # ++ optimum-neuron.optional-dependencies.neuronx;

    nncf = [
      # optimum-intel
    ]; # ++ optimum-intel.optional-dependencies.nncf;

    onnx = [
      optimum-onnx
    ];

    onnxruntime = [
      optimum-onnx
    ]
    ++ optimum-onnx.optional-dependencies.onnxruntime;

    openvino = [
      # optimum-intel
    ]; # ++ optimum-intel.optional-dependencies.openvino;
  };

  pyproject = true;
  pythonImportsCheck = [ "optimum" ];
  pythonRelaxDeps = [ "transformers" ];

  meta = {
    description = "Accelerate training and inference of Transformers and Diffusers with easy to use hardware optimization tools";
    homepage = "https://github.com/huggingface/optimum";
    changelog = "https://github.com/huggingface/optimum/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ natsukium ];
    mainProgram = "optimum-cli";
  };
}
