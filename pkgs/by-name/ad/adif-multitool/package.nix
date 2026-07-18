{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "adif-multitool";
  version = "0.1.22";

  src = fetchFromGitHub {
    owner = "flwyd";
    repo = "adif-multitool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UYnm4S4DP0c2ZkPkPScUHXdKiAz6JY9Lzdu4mAO49Dc=";
  };

  vendorHash = "sha256-Fin0DUvpNPqKXpbDVekvWZYghJIpMLY9IRr2wdbZczc=";
  proxyVendor = true;

  meta = {
    description = "Command-line program for working with ham logfiles";
    homepage = "https://github.com/flwyd/adif-multitool";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mafo ];
    mainProgram = "adifmt";
  };
})
