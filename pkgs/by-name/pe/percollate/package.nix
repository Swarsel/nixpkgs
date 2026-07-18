{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  chromium,
  makeWrapper,
}:

buildNpmPackage rec {
  pname = "percollate";
  version = "4.3.0";

  src = fetchFromGitHub {
    owner = "danburzo";
    repo = "percollate";
    rev = "v${version}";
    hash = "sha256-nu72jkqGt2ntlCxKptRlfTTd3SAVlv/QPTwkIUpVd2g=";
  };

  postPatch = ''
    substituteInPlace package.json --replace "git config core.hooksPath .git-hooks" ""
  '';

  nativeBuildInputs = [ makeWrapper ];
  npmDepsHash = "sha256-O74AVF3PwLzkWPAqTmfsxPefevvv3VRIstb0OI2/bQ0=";

  env = {
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
  };

  postInstall = ''
    wrapProgram $out/bin/percollate \
      --set PUPPETEER_EXECUTABLE_PATH ${chromium}/bin/chromium
  '';

  dontNpmBuild = true;
  # Dev dependencies include an unnecessary Java dependency (epubchecker)
  # https://github.com/danburzo/percollate/blob/v4.3.0/package.json#L40
  npmInstallFlags = [ "--omit=dev" ];

  meta = {
    description = "Command-line tool to turn web pages into readable PDF, EPUB, HTML, or Markdown docs";
    homepage = "https://github.com/danburzo/percollate";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.austinbutler ];
    mainProgram = "percollate";
  };
}
