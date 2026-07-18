{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "juicefs";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "juicedata";
    repo = "juicefs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-FACkhBYlJK3NcgYliqT/18djVB7sAo53oqosdFFkAtI=";
  };

  vendorHash = "sha256-LE6bpFSHhIRKaGlgn8nU8leOfcNH1ruKRv3vHZu0n/s=";
  doCheck = false; # requires network access

  postInstall = ''
    ln -s $out/bin/juicefs $out/bin/mount.juicefs
  '';

  excludedPackages = [ "sdk/java/libjfs" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/juicedata/juicefs/pkg/version.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Distributed POSIX file system built on top of Redis and S3";
    homepage = "https://www.juicefs.com/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
