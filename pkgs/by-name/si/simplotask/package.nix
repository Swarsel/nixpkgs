{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "simplotask";
  version = "1.20.1";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "spot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VZXtteRXzjxXtAOYXZHBXknOyegbaCAPPXyRtig3PIs=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;
  doCheck = false;

  postInstall = ''
    mv $out/bin/{secrets,spot-secrets}
    installManPage *.1
    installShellCompletion completions/*
  '';

  ldflags = [
    "-s -w"
    "-X main.revision=v${finalAttrs.version}"
  ];

  meta = {
    description = "Tool for effortless deployment and configuration management";
    homepage = "https://spot.umputun.dev/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "spot";
  };
})
