{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
buildNpmPackage (finalAttrs: {
  pname = "open-websearch";
  version = "2.1.9";

  src = fetchFromGitHub {
    owner = "Aas-ee";
    repo = "open-webSearch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZS56Eoy9IePLeyopv4AK6FU8+b1E8r/WPK6RYDvy6yA=";
  };

  strictDeps = true;
  npmDepsHash = "sha256-Ua20YOYr/D06eMQsgBgfN/W7F74wfjjHXL10XIB0nFA=";
  __structuredAttrs = true;

  meta = {
    description = "Web search MCP server";
    homepage = "https://github.com/Aas-ee/open-webSearch";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ReStranger ];
    platforms = lib.platforms.all;
    mainProgram = "open-websearch";
  };
})
