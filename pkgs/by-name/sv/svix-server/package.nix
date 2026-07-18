{
  lib,
  stdenv,
  fetchFromGitHub,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "svix-server";
  version = "1.96.1";

  src = fetchFromGitHub {
    owner = "svix";
    repo = "svix-webhooks";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NRzumAmgpqCfoLC0s6cAUcQYCFMFD6MElhDFpW79CQs=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    protobuf
  ];

  cargoHash = "sha256-IZ3YPEU4QpTia3ekvr1AQDZCrg4xUmEj82ZU0y/dDzM=";

  env = {
    OPENSSL_NO_VENDOR = 1;
    # needed for internal protobuf c wrapper library
    PROTOC = "${protobuf}/bin/protoc";
    PROTOC_INCLUDE = "${protobuf}/include";
  };

  # disable tests because they require postgres and redis to be running
  doCheck = false;
  sourceRoot = "${finalAttrs.src.name}/server";

  meta = {
    description = "Enterprise-ready webhooks service";
    homepage = "https://github.com/svix/svix-webhooks";
    changelog = "https://github.com/svix/svix-webhooks/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ techknowlogick ];
    mainProgram = "svix-server";
    broken = stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isDarwin; # aws-lc-sys currently broken on darwin x86_64
  };
})
