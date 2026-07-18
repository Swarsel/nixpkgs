{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "node-pre-gyp";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "node-pre-gyp";
    tag = "v${version}";
    hash = "sha256-9MADe6oY28MBAdQsu/ddVveZYwD4xeVNKUffhcvK+Q0=";
  };

  npmDepsHash = "sha256-yNu66HlkOVsYv60saTf7M4QuN9B2euYFu5WB7UAwhUw=";

  postInstall = ''
    mv $out/bin/@mapbox/node-pre-gyp $out/bin
    rmdir $out/bin/@mapbox
  '';

  dontNpmBuild = true;

  meta = {
    description = "Node.js tool for easy binary deployment of C++ addons";
    homepage = "https://github.com/mapbox/node-pre-gyp";
    changelog = "https://github.com/mapbox/node-pre-gyp/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "node-pre-gyp";
  };
}
