{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  protobuf,
  protoc-gen-go,
  protoc-gen-go-grpc,
  vectorscan,
}:

buildGoModule (finalAttrs: {
  pname = "secretscanner";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "deepfence";
    repo = "SecretScanner";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lTUZLuEiC9xpHYWn3uv4ZtbvHX6ETsjxacjd/O0kU8I=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
  ];

  buildInputs = [
    vectorscan
  ];

  vendorHash = "sha256-lB+fiSdflIYGw0hMN0a9IOtRcJwYEUPQqaeU7mAfSQs=";

  preBuild = ''
    # Compile proto files
    make -C agent-plugins-grpc go
  '';

  postInstall = ''
    mv $out/bin/SecretScanner $out/bin/$pname
  '';

  excludedPackages = [
    "./agent-plugins-grpc/proto" # No need to build submodules
  ];

  meta = {
    description = "Tool to find secrets and passwords in container images and file systems";
    homepage = "https://github.com/deepfence/SecretScanner";
    changelog = "https://github.com/deepfence/SecretScanner/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "secretscanner";
  };
})
