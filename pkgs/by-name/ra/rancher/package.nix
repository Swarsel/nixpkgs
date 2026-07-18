{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "rancher";
  version = "2.14.2";

  src = fetchFromGitHub {
    owner = "rancher";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SysEf7oe85htpwi2xy3Em82WuV+sTZCy2OlxoZLshYc=";
  };

  vendorHash = "sha256-sDSblZzRZ3StEMBeJbx2+hsSTKkuU3ixgLqR7vLfp3A=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/cli $out/bin/rancher
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/rancher | grep ${finalAttrs.version} > /dev/null
  '';

  ldflags = [
    "-w"
    "-s"
    "-X main.VERSION=${finalAttrs.version}"
    "-extldflags"
    "-static"
  ];

  meta = {
    description = "CLI tool for interacting with your Rancher Server";
    homepage = "https://github.com/rancher/cli";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "rancher";
  };
})
