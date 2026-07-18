{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "thunderbird-mcp";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "TKasperczyk";
    repo = "thunderbird-mcp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jrmHqToe+lJTpoG1QYaYHVk84PaO5zKAXLwr3Opl0A4=";
  };

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-D0DAjK/u59rOKNf5kCu/OYkch+4lZYgdHkuib0sqtIw=";
  doCheck = true;
  checkPhase = "npm test";
  # Tests use local mock servers.
  __darwinAllowLocalNetworking = true;
  dontNpmBuild = true;
  forceEmptyCache = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP server for Thunderbird - enables AI assistants to access email, contacts, and calendars";
    homepage = "https://github.com/TKasperczyk/thunderbird-mcp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
    mainProgram = "thunderbird-mcp";
  };
})
