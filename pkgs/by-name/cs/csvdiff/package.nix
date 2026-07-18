{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "csvdiff";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "aswinkarthik";
    repo = "csvdiff";
    rev = "v${finalAttrs.version}";
    hash = "sha256-66R5XxrNQ1YMMQicw0VCF/XzRo//5Gqdjlher/uMoTE=";
  };

  vendorHash = "sha256-rhOjBMCyfirEI/apL3ObHfKZeuNPGSt84R9lwCbRIpg=";

  meta = {
    description = "Fast diff tool for comparing csv files";
    homepage = "https://aswinkarthik.github.io/csvdiff/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ turion ];
    mainProgram = "csvdiff";
  };
})
