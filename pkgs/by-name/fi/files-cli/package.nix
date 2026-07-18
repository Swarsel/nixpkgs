{
  lib,
  fetchFromGitHub,
  buildGoModule,
  files-cli,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "files-cli";
  version = "2.15.381";

  src = fetchFromGitHub {
    owner = "files-com";
    repo = "files-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-p990MRYRaucbORv13k8q1lXIKdtvylEfJC6iufpq2F0=";
  };

  vendorHash = "sha256-nlYyCCO+DKqnZZ1NUcvXttDfPMlcasaJl6H/YZUZqjI=";
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/files-cli --help

    runHook postInstallCheck
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.tests = {
    version = testers.testVersion {
      version = "files-cli version ${finalAttrs.version}";
      command = "files-cli -v";
      package = files-cli;
    };
  };

  meta = {
    description = "Files.com Command Line App for Windows, Linux, and macOS";
    homepage = "https://developers.files.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kashw2 ];
    mainProgram = "files-cli";
  };

})
