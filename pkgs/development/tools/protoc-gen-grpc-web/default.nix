{
  lib,
  stdenv,
  fetchFromGitHub,
  protobuf,
  isStatic ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "protoc-gen-grpc-web";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "grpc";
    repo = "grpc-web";
    rev = finalAttrs.version;
    sha256 = "sha256-yqiSuqan4vynE3AS8OnYdzA+3AVlVFTBkxTuJe17114=";
  };

  strictDeps = true;
  nativeBuildInputs = [ protobuf ];
  buildInputs = [ protobuf ];

  makeFlags = [
    "PREFIX=$(out)"
    "STATIC=${lib.boolToYesNo isStatic}"
  ];

  doCheck = true;
  nativeCheckInputs = [ protobuf ];

  checkPhase = ''
    runHook preCheck

    CHECK_TMPDIR="$TMPDIR/proto"
    mkdir -p "$CHECK_TMPDIR"

    protoc \
      --proto_path="$src/packages/grpc-web/test/protos" \
      --plugin="./protoc-gen-grpc-web" \
      --grpc-web_out="import_style=commonjs,mode=grpcwebtext:$CHECK_TMPDIR" \
      echo.proto

    # check for grpc-web generated file
    [ -f "$CHECK_TMPDIR/echo_grpc_web_pb.js" ]

    runHook postCheck
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/javascript/net/grpc/web/generator";

  meta = {
    description = "gRPC web support for Google's protocol buffers";
    homepage = "https://github.com/grpc/grpc-web";
    changelog = "https://github.com/grpc/grpc-web/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    platforms = lib.platforms.unix;
    mainProgram = "protoc-gen-grpc-web";
  };
})
