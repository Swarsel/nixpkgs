{
  lib,
  fetchFromGitLab,
  buildGoModule,
  git,
}:
let
  data = lib.importJSON ../data.json;
in
buildGoModule (finalAttrs: {
  pname = "gitlab-workhorse";
  version = "18.11.6";

  # nixpkgs-update: no auto update
  src = fetchFromGitLab {
    owner = data.owner;
    repo = data.repo;
    rev = data.rev;
    sha256 = data.repo_hash;
  };

  buildInputs = [ git ];
  vendorHash = "sha256-X1+neA2g61BR1VRKXzeqNath0+SYXRbU4vzEg1KD2sY=";
  doCheck = false;
  ldflags = [ "-X main.Version=${finalAttrs.version}" ];
  prodyVendor = true;
  sourceRoot = "${finalAttrs.src.name}/workhorse";

  meta = {
    homepage = "http://www.gitlab.com/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gitlab ];
  };
})
