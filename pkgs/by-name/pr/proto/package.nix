{
  lib,
  stdenv,
  fetchFromGitHub,
  libiconv,
  makeBinaryWrapper,
  perl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "proto";
  version = "0.58.2";

  src = fetchFromGitHub {
    owner = "moonrepo";
    repo = "proto";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fITyBLT4SyQ7q3zMJ2JpunsBjdZtgiGA19g09PKQcL8=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
    perl
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv

  ];

  cargoHash = "sha256-tK/nb6g8fjhdCciI5mgq+mvUBwXPsak1VNk8pcWlQrk=";
  # Tests requires network access
  doCheck = false;

  postInstall = ''
    # proto looks up a proto-shim executable file in $PROTO_LOOKUP_DIR
    wrapProgram $out/bin/proto \
      --set PROTO_LOOKUP_DIR $out/bin
  '';

  cargoBuildFlags = [
    "--bin proto"
    "--bin proto-shim"
  ];

  meta = {
    description = "Pluggable multi-language version manager";

    longDescription = ''
      proto is a pluggable next-generation version manager for multiple programming languages. A unified toolchain.
    '';

    homepage = "https://moonrepo.dev/proto";
    changelog = "https://github.com/moonrepo/proto/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nokazn ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "proto";
  };
})
