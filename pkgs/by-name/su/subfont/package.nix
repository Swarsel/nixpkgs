{
  lib,
  fetchurl,
  buildNpmPackage,
  cairo,
  nodejs_22,
  pango,
  pixman,
  pkg-config,
  testers,
}:

let
  pname = "subfont";
  version = "7.2.3";
  src = fetchurl {
    url = "https://registry.npmjs.org/subfont/-/subfont-${version}.tgz";
    hash = "sha256-daHPt03dPBCWYXFS8x1SNTRlkmCCdWmmondur6fRBgY=";
  };
in
buildNpmPackage (finalAttrs: {
  inherit pname version src;

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    cairo
    pango
    pixman
  ];

  npmDepsHash = "sha256-ocCVdUtKiWNVzxZljcb2Y+4u3r34drbcNyfKT3Rj1mY=";
  env.PUPPETEER_SKIP_DOWNLOAD = true;
  dontNpmBuild = true;
  nodejs = nodejs_22;

  passthru.tests.version = testers.testVersion {
    inherit version;
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Command line tool to optimize webfont loading by aggressively subsetting based on font use, self-hosting of Google fonts and preloading";
    homepage = "https://github.com/Munter/subfont";
    changelog = "https://github.com/Munter/subfont/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ dav-wolff ];
    mainProgram = "subfont";
  };
})
