{
  lib,
  stdenv,
  bundlerEnv,
  bundlerUpdateScript,
  makeWrapper,
  ruby,
}:
let
  rubyEnv = bundlerEnv {
    inherit ruby;
    gemdir = ./.;
    name = "terraspace";
  };
in
stdenv.mkDerivation {
  pname = "terraspace";
  version = (import ./gemset.nix).terraspace.version;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${rubyEnv}/bin/terraspace $out/bin/terraspace
    wrapProgram $out/bin/terraspace \
      --prefix PATH : ${lib.makeBinPath [ rubyEnv.ruby ]}
  '';

  dontUnpack = true;
  passthru.updateScript = bundlerUpdateScript "terraspace";

  meta = {
    description = "Terraform framework that provides an organized structure, and keeps your code DRY";
    homepage = "https://github.com/boltops-tools/terraspace";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mislavzanic ];
    platforms = ruby.meta.platforms;
    mainProgram = "terraspace";
  };
}
