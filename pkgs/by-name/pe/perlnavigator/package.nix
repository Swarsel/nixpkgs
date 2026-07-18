{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

let
  version = "0.6.3";
  src = fetchFromGitHub {
    owner = "bscan";
    repo = "PerlNavigator";
    rev = "v${version}";
    hash = "sha256-CNsgFf+W7YQwAR++GwfTka4Cy8woRu02BQIJRmRAxK4=";
  };
  browser-ext = buildNpmPackage {
    inherit version src;
    pname = "perlnavigator-web-server";
    npmDepsHash = "sha256-PJKW+ni2wKw1ivkgQsL6g0jaxoYboa3XpVEEwgT4jWo=";

    installPhase = ''
      cp -r . "$out"
    '';

    dontNpmBuild = true;
    sourceRoot = "${src.name}/browser-ext";
  };
  client = buildNpmPackage {
    inherit version src;
    pname = "perlnavigator-client";
    npmDepsHash = "sha256-CM0l+D1VNkXBrZQHQGDiB/vAxMvpbHYoYlIugoLxSfA=";

    installPhase = ''
      cp -r . "$out"
    '';

    dontNpmBuild = true;
    sourceRoot = "${src.name}/client";
  };
  server = buildNpmPackage {
    inherit version src;
    pname = "perlnavigator-server";
    npmDepsHash = "sha256-TxK3ba9T97p8TBlULHUov6YX7WRl2QMq6TiNHxBoQeY=";

    installPhase = ''
      cp -r . "$out"
    '';

    dontNpmBuild = true;
    sourceRoot = "${src.name}/server";
  };
in
buildNpmPackage rec {
  inherit version src;
  pname = "perlnavigator";

  postPatch = ''
    sed -i /postinstall/d package.json

    rm -r browser-ext client server
    cp -r ${browser-ext} browser-ext
    cp -r ${client} client
    cp -r ${server} server
    chmod +w browser-ext client server
  '';

  npmDepsHash = "sha256-nEinmgrbbFC+nkfTwu9djiUS+tj0VM4WKl2oqKpcGtM=";

  env = {
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = 1;
  };

  postInstall = ''
    cp -r ${browser-ext}/node_modules "$out/lib/node_modules/perlnavigator/browser-ext"
    cp -r ${client}/node_modules "$out/lib/node_modules/perlnavigator/client"
    cp -r ${server}/node_modules "$out/lib/node_modules/perlnavigator/server"
  '';

  npmBuildScript = "compile";

  meta = {
    description = "Perl Language Server that includes syntax checking, perl critic, and code navigation";
    homepage = "https://github.com/bscan/PerlNavigator/tree/main/server";
    changelog = "https://github.com/bscan/PerlNavigator/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "perlnavigator";
  };
}
