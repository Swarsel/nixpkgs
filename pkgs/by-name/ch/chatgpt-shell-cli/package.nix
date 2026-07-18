{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  glow,
  jq,
  makeWrapper,
}:

let
  pname = "chatgpt-shell-cli";

  # no tags
  version = "master";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "0xacx";
    repo = "chatgpt-shell-cli";
    tag = version;
    hash = "sha256-hYLrUya4UCsIB1J/n+jp1jFRCEqnGFJOr3ATxm0zwdY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm755 chatgpt.sh -t $out/bin

    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/chatgpt.sh \
      --prefix PATH : ${
        lib.makeBinPath [
          jq
          curl
          glow
        ]
      }
  '';

  meta = {
    description = "Simple shell script to use OpenAI's ChatGPT and DALL-E from the terminal. No Python or JS required";
    homepage = "https://github.com/0xacx/chatGPT-shell-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jfvillablanca ];
  };
}
