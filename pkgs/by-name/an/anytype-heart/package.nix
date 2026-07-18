{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  protobuf,
  protoc-gen-grpc-web,
  protoc-gen-js,
  tantivy-go,
}:

let
  arch =
    {
      aarch64-darwin = "darwin-arm64";
      aarch64-linux = "linux-arm64-musl";
      # https://github.com/anyproto/anytype-heart/blob/f33a6b09e9e4e597f8ddf845fc4d6fe2ef335622/pkg/lib/localstore/ftsearch/ftsearchtantivy.go#L3
      x86_64-linux = "linux-amd64-musl";
    }
    .${stdenv.hostPlatform.system}
      or (throw "anytype-heart not supported on ${stdenv.hostPlatform.system}");
in
buildGoModule (finalAttrs: {
  pname = "anytype-heart";
  # Use only versions specified in anytype-ts middleware.version file:
  #  https://github.com/anyproto/anytype-ts/blob/v<anytype-ts-version>/middleware.version
  version = "0.50.8";

  # Update only together with 'anytype' package.
  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "anyproto";
    repo = "anytype-heart";
    tag = "v${finalAttrs.version}";
    hash = "sha256-h59Vnmv+iB0NbLQPCHPlmHBDaYoFimrZP/4Cv/IQ7b8=";
  };

  nativeBuildInputs = [
    protoc-gen-grpc-web
    protoc-gen-js
    protobuf
  ];

  vendorHash = "sha256-uJ/Z2zxqIne3UuxAglZejoqHV/IchYdPhefL9K51U2I=";
  env.CGO_ENABLED = 1;

  preBuild = ''
    mkdir -p deps/libs/${arch}
    cp ${tantivy-go}/lib/libtantivy_go.a deps/libs/${arch}
  '';

  # disable tests to save time, as it's mostly built by users, not CI
  doCheck = false;

  postInstall = ''
    mv $out/bin/grpcserver $out/bin/anytypeHelper
    mkdir -p $out/lib/protos
    find pb -type f -name "*.proto" -exec cp {} $out/lib/protos/ \;
    find pkg/lib/pb -type f -name "*.proto" -exec cp {} $out/lib/protos/ \;

    mkdir -p $out/lib/json/generated
    cp pkg/lib/bundle/system*.json $out/lib/json/generated
    cp pkg/lib/bundle/internal*.json $out/lib/json/generated

    mkdir -p $out/share
    cp LICENSE.md $out/share
  '';

  proxyVendor = true;
  subPackages = [ "cmd/grpcserver" ];

  tags = [
    "nosigar"
    "nowatchdog"
  ];

  meta = {
    description = "Shared library for Anytype clients";
    homepage = "https://anytype.io/";
    changelog = "https://github.com/anyproto/anytype-heart/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unfreeRedistributable;

    maintainers = with lib.maintainers; [
      autrimpo
      adda
      kira-bruneau
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    broken = stdenv.hostPlatform.isDarwin;
  };
})
