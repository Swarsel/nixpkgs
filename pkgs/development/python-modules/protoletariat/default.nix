{
  lib,
  fetchFromGitHub,
  astunparse,
  buildPythonPackage,
  click,
  grpcio-tools,
  mypy-protobuf_3_6,
  pkgs,
  poetry-core,
  protobuf,
  pytestCheckHook,
  writableTmpDirAsHomeHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "protoletariat";
  version = "3.3.10";

  src = fetchFromGitHub {
    owner = "cpcloud";
    repo = "protoletariat";
    tag = finalAttrs.version;
    hash = "sha256-oaZmgen/7WkX+nNuphrcyniL7Z/OaeqlcnbCnqR5h0w=";
  };

  postPatch = ''
    substituteInPlace protoletariat/__main__.py \
      --replace-fail 'default="protoc",' 'default="${lib.getExe' pkgs.protobuf "protoc"}",'
  '';

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
    mypy-protobuf_3_6
  ];

  build-system = [ poetry-core ];

  dependencies = [
    astunparse
    click
    grpcio-tools
    protobuf
  ];

  pyproject = true;
  pythonImportsCheck = [ "protoletariat" ];

  pythonRelaxDeps = [
    "protobuf"
  ];

  meta = {
    description = "Python protocol buffers for the rest of us";
    homepage = "https://github.com/cpcloud/protoletariat";
    changelog = "https://github.com/cpcloud/protoletariat/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
