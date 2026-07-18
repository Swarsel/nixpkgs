{
  lib,
  fetchFromGitHub,
  brotli,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "butler";
  version = "15.27.0";

  src = fetchFromGitHub {
    owner = "itchio";
    repo = "butler";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AnyZhfBjajWAM/pzCQjHOjY3sOQzU20y+LWHBZxbU3Y=";
  };

  buildInputs = [ brotli ];
  vendorHash = "sha256-zDovN9J6IOE3TrXP60PPcsIc0PpXyEaqSR8i4i9MiHk=";
  doCheck = false; # disabled because the tests don't work in a non-FHS compliant environment.

  meta = {
    description = "Command-line itch.io helper";
    homepage = "http://itch.io";
    changelog = "https://github.com/itchio/butler/releases/tag/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ naelstrof ];
  };
})
