{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "reveal-md";
  version = "6.1.4";

  src = fetchFromGitHub {
    owner = "webpro";
    repo = "reveal-md";
    rev = version;
    hash = "sha256-5lYC4v+Jvm1OdWrkU/cn1I1jd0B1C+AvACCiGUBv+h0=";
  };

  npmDepsHash = "sha256-+SYAgY3C3LWwi8qTMy7MyfOgGaw2EohscoX5QIRafxM=";

  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    npm run test

    runHook postCheck
  '';

  dontNpmBuild = true;

  meta = {
    description = "Get beautiful reveal.js presentations from your Markdown files";
    homepage = "https://github.com/webpro/reveal-md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sagikazarmark ];
    mainProgram = "reveal-md";
  };
}
