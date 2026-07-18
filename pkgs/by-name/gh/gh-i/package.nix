{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gh-i";
  version = "0.0.10";

  src = fetchFromGitHub {
    owner = "gennaro-tedesco";
    repo = "gh-i";
    rev = "v${finalAttrs.version}";
    hash = "sha256-k1xfQxRh8T0SINtbFlIVNFEODYU0RhBAkjudOv1bLvw=";
  };

  vendorHash = "sha256-eqSAwHFrvBxLl5zcZyp3+1wTf7+JmpogFBDuVgzNm+w=";
  ldflags = [ "-s" ];

  meta = {
    description = "Search github issues interactively";
    homepage = "https://github.com/gennaro-tedesco/gh-i";
    changelog = "https://github.com/gennaro-tedesco/gh-i/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "gh-i";
  };
})
