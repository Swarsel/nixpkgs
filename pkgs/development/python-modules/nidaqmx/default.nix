{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  deprecation,
  distro,
  grpcio,
  hightime,
  numpy,
  poetry-core,
  protobuf,
  python-decouple,
  requests,
  sphinx,
  sphinx-rtd-theme,
  toml,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "nidaqmx";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "ni";
    repo = "nidaqmx-python";
    tag = version;
    hash = "sha256-Khydb14+yJKWYcO4pROfbainXw3bHceXK5Gc9GCIYNo=";
  };

  # Tests require hardware
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    click
    deprecation
    hightime
    numpy
    python-decouple
    requests
    tzlocal
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    distro
  ];

  optional-dependencies = {
    docs = [
      sphinx
      sphinx-rtd-theme
      toml
    ];

    grpc = [
      grpcio
      protobuf
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "nidaqmx" ];

  meta = {
    description = "API for interacting with the NI-DAQmx driver";
    homepage = "https://github.com/ni/nidaqmx-python";
    changelog = "https://github.com/ni/nidaqmx-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fsagbuya ];
  };
}
