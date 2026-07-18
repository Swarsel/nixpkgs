{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "trillian";
  version = "1.7.3";

  src = fetchFromGitHub {
    owner = "google";
    repo = "trillian";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-QOR98Xpf2iwGpqzEuB58gMsbYITiksMX4JmfqiKjeVw=";
  };

  vendorHash = "sha256-PomzPYtLEDx0mjTTidfp9dlvnW4mcVIka5AekPNYU2g=";

  subPackages = [
    "cmd/trillian_log_server"
    "cmd/trillian_log_signer"
    "cmd/createtree"
    "cmd/deletetree"
    "cmd/updatetree"
  ];

  meta = {
    description = "Transparent, highly scalable and cryptographically verifiable data store";
    homepage = "https://github.com/google/trillian";
    license = [ lib.licenses.asl20 ];
    maintainers = [ ];
  };
})
