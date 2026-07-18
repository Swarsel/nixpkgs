{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "figurine";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "arsham";
    repo = "figurine";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5UCvC3gweOqEzJdTob0mgmljMneYZ4m3G9SD03Xg9tM=";
  };

  vendorHash = "sha256-4A40TbUeqsw7RHO/1qbAURE1ntarh2GmtPgE7dglGoc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.currentSha=${finalAttrs.src.rev}"
  ];

  meta = {
    description = "Print your name in style";
    homepage = "https://github.com/arsham/figurine";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ironicbadger ];
    mainProgram = "figurine";
  };
})
