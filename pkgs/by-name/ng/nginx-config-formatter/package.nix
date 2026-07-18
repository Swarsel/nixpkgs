{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nginx-config-formatter";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "slomkowski";
    repo = "nginx-config-formatter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HB1knL/q1G2z6RyVCsOyIKpp4O6x68/93ccvox1FKGQ=";
  };

  strictDeps = true;
  buildInputs = [ python3 ];
  doCheck = true;
  nativeCheckInputs = [ python3 ];

  checkPhase = ''
    python3 $src/test_nginxfmt.py
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m 0755 $src/nginxfmt.py $out/bin/nginxfmt
  '';

  doInstallCheck = true;

  # We can't do a version check because there is no version command
  # but we do want to check that python3 is available
  installCheckPhase = ''
    $out/bin/nginxfmt --help
  '';

  meta = {
    description = "Nginx config file formatter";
    homepage = "https://github.com/slomkowski/nginx-config-formatter";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ Baughn ];
    mainProgram = "nginxfmt";
  };
})
