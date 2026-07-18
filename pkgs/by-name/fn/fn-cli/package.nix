{
  lib,
  fetchFromGitHub,
  buildGoModule,
  docker,
}:

buildGoModule (finalAttrs: {
  pname = "fn";
  version = "0.6.61";

  src = fetchFromGitHub {
    owner = "fnproject";
    repo = "cli";
    rev = finalAttrs.version;
    hash = "sha256-uw4fH3PyuAnNEhrvw0dl2jJxP4jau3tVuAjzSgeu1Lw=";
  };

  buildInputs = [
    docker
  ];

  vendorHash = null;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    mv $out/bin/cli $out/bin/fn
  '';

  subPackages = [ "." ];

  meta = {
    description = "Command-line tool for the fn project";
    homepage = "https://fnproject.io";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.c4605 ];
    mainProgram = "fn";
  };
})
