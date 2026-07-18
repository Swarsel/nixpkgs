{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ktop";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "vladimirvivien";
    repo = "ktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5iFFYTZq5DcMYVnW90MKVDchVXzjXOPd5BeYcrqL9pQ=";
  };

  vendorHash = "sha256-qNrjyMMsFE2FmIJc46fYq08b3XFFZeLlspth5anjMm8=";
  doCheck = false;

  postInstall = ''
    rm $out/bin/hack
  '';

  excludedPackages = [ ".ci" ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/vladimirvivien/ktop/buildinfo.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Top-like tool for your Kubernetes cluster";

    longDescription = ''
      Following the tradition of Unix/Linux top tools, ktop is a tool that displays useful metrics information about nodes, pods, and other workload resources running in a Kubernetes cluster.
    '';

    homepage = "https://github.com/vladimirvivien/ktop/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ qjoly ];
    mainProgram = "ktop";
  };
})
