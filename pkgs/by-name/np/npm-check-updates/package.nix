{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "npm-check-updates";
  version = "19.3.2";

  src = fetchFromGitHub {
    owner = "raineorshine";
    repo = "npm-check-updates";
    tag = "v${version}";
    hash = "sha256-rQRBPfP7w9a2qCjOxNtl9mmSJiYZYbJyyOh3FEfckxk=";
  };

  postPatch = ''
    sed -i '/"prepare"/d' package.json
  '';

  npmDepsHash = "sha256-wcpaJv8ji5Yr8Whp+fk+CYp4w3WcnYo20q/Injf/7Z8=";
  makeCacheWritable = true;

  meta = {
    description = "Find newer versions of package dependencies than what your package.json allows";
    homepage = "https://github.com/raineorshine/npm-check-updates";
    changelog = "https://github.com/raineorshine/npm-check-updates/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ flosse ];
    mainProgram = "ncu";
  };
}
