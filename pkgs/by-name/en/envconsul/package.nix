{
  lib,
  fetchFromGitHub,
  buildGoModule,
  envconsul,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "envconsul";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "envconsul";
    rev = "v${finalAttrs.version}";
    hash = "sha256-F04Cq9iOGP+z6x59pkRye1Fx8ZAgsSnbr7tGsNK2LxM=";
  };

  vendorHash = "sha256-poRw02L/py6H8Dtd4gAqJ70lFJOYjzYU7lRkpHS8u8A=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/hashicorp/envconsul/version.Name=envconsul"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = envconsul;
  };

  meta = {
    description = "Read and set environmental variables for processes from Consul";
    homepage = "https://github.com/hashicorp/envconsul/";
    license = lib.licenses.mpl20;
    mainProgram = "envconsul";
  };
})
