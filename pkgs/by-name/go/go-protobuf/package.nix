{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "go-protobuf";
  version = "1.5.4";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "protobuf";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-AfyZ6xlqmrsVqtoKV1XMEo/Vba9Kpu1EgwfF6pPSZ64=";
  };

  vendorHash = "sha256-jGAWUgW0DA7EwmlzVxnBmtbf2dp+P4Qwcb8mTAEhUi4=";

  meta = {
    description = "Go bindings for protocol buffer";
    homepage = "https://github.com/golang/protobuf";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ lewo ];
  };
})
