{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "gdrive";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "prasmussen";
    repo = "gdrive";
    rev = finalAttrs.version;
    hash = "sha256-2dJmGFHfGSroucn4WgiV2NExBs5wtMDe2kX1jDBwbRs=";
  };

  patches = [
    # Add Go Modules support
    (fetchpatch {
      hash = "sha256-W8o2ZfhQFJISHfPavjx9sw5UB6xOZ7qRW4L0bHNddS8=";
      url = "https://github.com/prasmussen/gdrive/pull/585/commits/faa6fc3dc104236900caa75eb22e9ed2e5ecad42.patch";
    })
  ];

  vendorHash = "sha256-sHNP1YwnZYu0UfgLx5+gxJmesY8Brt7rr9cptlyk9Bk=";
  deleteVendor = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Command line utility for interacting with Google Drive";
    homepage = "https://github.com/prasmussen/gdrive";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.rzetterberg ];
    mainProgram = "gdrive";
  };
})
