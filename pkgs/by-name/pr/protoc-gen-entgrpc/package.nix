{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "protoc-gen-entgrpc";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "ent";
    repo = "contrib";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-kI+/qbWvOxcHKee7jEFBs5Bb+5MPGunAsB6d1j9fhp8=";
  };

  vendorHash = "sha256-tOt6Uxo4Z2zJrTjyTPoqHGfUgxFmtB+xP+kB+S6ez84=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "entproto/cmd/protoc-gen-entgrpc" ];

  meta = {
    description = "Generator of an implementation of the service interface for ent protobuff";
    homepage = "https://entgo.io/";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "protoc-gen-entgrpc";
    downloadPage = "https://github.com/ent/contrib/";
  };
})
