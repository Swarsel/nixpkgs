{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
}:

buildGoModule (finalAttrs: {
  pname = "semver";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "catouc";
    repo = "semver-go";
    rev = "v${finalAttrs.version}";
    sha256 = "0v3j7rw917wnmp4lyjscqzk4qf4azfiz70ynbq3wl4gwp1m783vv";
  };

  nativeBuildInputs = [ git ];
  vendorHash = null;

  meta = {
    description = "Small CLI to fish out the current or next semver version from a git repository";
    homepage = "https://github.com/catouc/semver-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ catouc ];
    mainProgram = "semver";
  };
})
