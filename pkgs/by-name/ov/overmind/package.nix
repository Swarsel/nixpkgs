{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  tmux,
  which,
}:

buildGoModule (finalAttrs: {
  pname = "overmind";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "DarthSim";
    repo = "overmind";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-wX29nFmzmbxbaXtwIWZNvueXFv9SKIOqexkc5pEITpw=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-XhF4oizOZ6g0351Q71Wp9IA3aFpocC5xGovDefIoL78=";

  postInstall = ''
    wrapProgram "$out/bin/overmind" --prefix PATH : "${
      lib.makeBinPath [
        tmux
        which
      ]
    }"
  '';

  meta = {
    description = "Process manager for Procfile-based applications and tmux";
    homepage = "https://github.com/DarthSim/overmind";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
    mainProgram = "overmind";
  };
})
