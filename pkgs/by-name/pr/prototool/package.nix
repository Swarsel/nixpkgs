{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  protobuf,
}:

buildGoModule (finalAttrs: {
  pname = "prototool";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "uber";
    repo = "prototool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-T6SjjyHC4j5du2P4Emcfq/ZFbuCpMPPJFJTHb/FNMAo=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-W924cy6bd3V/ep3JmzUCV7iuYNukEetr90SKmLMH0j8=";
  doCheck = false;

  postInstall = ''
    wrapProgram "$out/bin/prototool" \
      --prefix PROTOTOOL_PROTOC_BIN_PATH : "${protobuf}/bin/protoc" \
      --prefix PROTOTOOL_PROTOC_WKT_PATH : "${protobuf}/include"
  '';

  subPackages = [ "cmd/prototool" ];

  meta = {
    description = "Your Swiss Army Knife for Protocol Buffers";
    homepage = "https://github.com/uber/prototool";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "prototool";
  };
})
