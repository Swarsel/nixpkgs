{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  kubectl,
}:

buildGoModule (finalAttrs: {
  pname = "gsctl";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "giantswarm";
    repo = "gsctl";
    rev = finalAttrs.version;
    sha256 = "sha256-eemPsrSFwgUR1Jz7283jjwMkoJR38QiaiilI9G0IQuo=";
  };

  patches = [
    ./go120-compatibility.patch
  ];

  postPatch = ''
    # fails on sandbox
    rm commands/root_test.go
  '';

  vendorHash = "sha256-6b4H8YAY8d/qIGnnGPYZoXne1LXHLsc0OEq0lCeqivo=";
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    kubectl
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/giantswarm/gsctl/buildinfo.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Giant Swarm command line interface";
    homepage = "https://github.com/giantswarm/gsctl";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ joesalisbury ];
    mainProgram = "gsctl";
  };
})
