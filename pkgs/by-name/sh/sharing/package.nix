{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "sharing";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "parvardegr";
    repo = "sharing";
    rev = "v${version}";
    hash = "sha256-y5tAbyRGxr6lagU/+pLBN0VIpk3+SzKyXOehQk6NW+M=";
  };

  npmDepsHash = "sha256-2DwFkkoODDuLOxF63F1ywoXzjcMn/+H2ycRWlJlNcCI=";
  env.NODE_OPTIONS = "--openssl-legacy-provider";
  dontNpmBuild = true;
  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Command-line tool to share directories and files to mobile devices";
    homepage = "https://github.com/parvardegr/sharing";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ChaosAttractor ];
  };
}
