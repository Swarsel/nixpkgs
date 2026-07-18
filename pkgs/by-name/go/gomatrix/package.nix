{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gomatrix";
  version = "101.0.0";

  src = fetchFromGitHub {
    owner = "GeertJohan";
    repo = "gomatrix";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VeRHVR8InfU+vEw2F/w3KFbNVSKS8ziRlQ98f3cuBfM=";
  };

  vendorHash = "sha256-yQSsxiWkihpoYBH9L6by/D2alqECoUEG4ei5T+B9gPs=";
  doCheck = false;

  meta = {
    description = ''Displays "The Matrix" in a terminal'';
    homepage = "https://github.com/GeertJohan/gomatrix";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ skykanin ];
    mainProgram = "gomatrix";
  };
})
