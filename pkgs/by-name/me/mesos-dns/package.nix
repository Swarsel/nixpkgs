{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mesos-dns";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "m3scluster";
    repo = "mesos-dns";
    tag = "v${finalAttrs.version}";
    hash = "sha256-922FWRqKGBFB8zQf9nAtlym3b7Fjcg+uaIqEKeRZSro=";
  };

  vendorHash = "sha256-l1y3CaGG1ykJnGit81D+E+jB4RUYneQzRMTvOPCH+jk=";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  meta = {
    description = "DNS-based service discovery for Mesos";
    homepage = "https://m3scluster.github.io/mesos-dns/";
    changelog = "https://github.com/m3scluster/mesos-dns/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "mesos-dns";
  };
})
