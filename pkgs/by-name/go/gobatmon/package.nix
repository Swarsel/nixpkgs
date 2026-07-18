{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gobatmon";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ulinja";
    repo = "gobatmon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-morcsU9RhY17XlaDC6J0uDRYiSYjnXquFjuOh7AEKkA=";
  };

  vendorHash = "sha256-WUTGAYigUjuZLHO1YpVhFSWpvULDZfGMfOXZQqVYAfs=";

  meta = {
    description = "Simple battery level monitor for Linux written in Go";
    homepage = "https://github.com/ulinja/gobatmon";
    changelog = "https://github.com/ulinja/gobatmon/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ ulinja ];
    platforms = lib.platforms.linux;
    mainProgram = "gobatmon";
    downloadPage = "https://github.com/ulinja/gobatmon/releases/latest";
  };
})
