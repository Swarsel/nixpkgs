{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "carto";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "carto";
    rev = "v${version}";
    hash = "sha256-TylMgb2EI52uFmVeMJiQltgNCSh6MutFwUjsYC7gfEA=";
  };

  npmDepsHash = "sha256-8M9hze71bQWhyxcXeI/EOr0SQ+tx8Lb9LfvnGxYYo0A=";

  postInstall = ''
    # Remove broken symlinks
    find "$out/lib/node_modules" -xtype l -delete
  '';

  dontNpmBuild = true;

  meta = {
    description = "Mapnik stylesheet compiler";
    homepage = "https://github.com/mapbox/carto";
    changelog = "https://github.com/mapbox/carto/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Luflosi ];
    mainProgram = "carto";
  };
}
