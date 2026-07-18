{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nixosTests,
}:

buildGoModule (finalAttrs: {
  pname = "minio-client";
  version = "2025-08-13T08-35-41Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "mc";
    rev = "RELEASE.${finalAttrs.version}";
    hash = "sha256-X4SNccBm+Fr1wiiElDFCCXwcPc6xVTGx+xIBL2nsbnE=";
  };

  vendorHash = "sha256-0ERiUx114EyoooPIVMCjiDkPb4/D0ZC/YuG14+30NPw=";
  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/mc --version | grep ${finalAttrs.version} > /dev/null
  '';

  patchPhase = ''
    sed -i "s/Version.*/Version = \"${finalAttrs.version}\"/g" cmd/build-constants.go
    sed -i "s/ReleaseTag.*/ReleaseTag = \"RELEASE.${finalAttrs.version}\"/g" cmd/build-constants.go
    sed -i "s/CommitID.*/CommitID = \"${finalAttrs.src.rev}\"/g" cmd/build-constants.go
  '';

  subPackages = [ "." ];
  passthru.tests.minio = nixosTests.minio;

  meta = {
    description = "Replacement for ls, cp, mkdir, diff and rsync commands for filesystems and object storage";
    homepage = "https://github.com/minio/mc";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      bachp
      ryan4yin
    ];

    mainProgram = "mc";
  };
})
