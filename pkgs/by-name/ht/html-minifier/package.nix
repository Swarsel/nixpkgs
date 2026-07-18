{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "html-minifier";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "kangax";
    repo = "html-minifier";
    rev = "v${version}";
    hash = "sha256-OAykAqBxgr7tbeXXfSH23DALf7Eoh3VjDKNKWGAL3+A=";
  };

  npmDepsHash = "sha256-VWXc/nBXgvSE/DoLHR4XTFQ5kuwWC1m0/cj1CndfPH8=";

  postInstall = ''
    find $out/lib/node_modules -xtype l -delete
  '';

  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Highly configurable, well-tested, JavaScript-based HTML minifier";
    homepage = "https://github.com/kangax/html-minifier";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chris-martin ];
    mainProgram = "html-minifier";
  };
}
