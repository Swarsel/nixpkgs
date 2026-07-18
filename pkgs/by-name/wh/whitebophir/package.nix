{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
  runtimeShell,
}:

buildNpmPackage rec {
  inherit nodejs;
  pname = "whitebophir";
  version = "1.19.1";

  src = fetchFromGitHub {
    owner = "lovasoa";
    repo = "whitebophir";
    rev = "v${version}";
    hash = "sha256-4T7s9WrpyHVPcw0QY0C0sczDJYKzA4bAAfEv8q2pOy4=";
  };

  npmDepsHash = "sha256-mKDkkX7vWrnfEg1D65bqn/MtyUS0DKjTtkDW6ebso7g=";

  postInstall = ''
    out_whitebophir=$out/lib/node_modules/whitebophir

    mkdir $out/bin
    cat <<EOF > $out/bin/whitebophir
    #!${runtimeShell}
    exec ${nodejs}/bin/node $out_whitebophir/server/server.js
    EOF
    chmod +x $out/bin/whitebophir
  '';

  dontNpmBuild = true;
  # geckodriver tries to access network
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Online collaborative whiteboard that is simple, free, easy to use and to deploy";
    homepage = "https://github.com/lovasoa/whitebophir";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ iblech ];
    platforms = lib.platforms.unix;
    mainProgram = "whitebophir";
  };
}
