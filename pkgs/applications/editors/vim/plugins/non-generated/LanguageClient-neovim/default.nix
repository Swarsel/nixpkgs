{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  vimUtils,
}:
let
  version = "0.1.161";
  src = fetchFromGitHub {
    owner = "autozimu";
    repo = "LanguageClient-neovim";
    tag = version;
    hash = "sha256-Z9S2ie9RxJCIbmjSV/Tto4lK04cZfWmK3IAy8YaySVI=";
  };
  LanguageClient-neovim-bin = rustPlatform.buildRustPackage {
    inherit version src;
    pname = "LanguageClient-neovim-bin";
    cargoHash = "sha256-43alR84MktYTmsKeUMm4gK8AjUIkGqcsuFeQPusBKD0=";

    cargoPatches = [
      ./traitobject.patch
    ];
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "LanguageClient-neovim";
  propagatedBuildInputs = [ LanguageClient-neovim-bin ];

  preFixup = ''
    substituteInPlace "$out"/autoload/LanguageClient.vim \
      --replace-fail \
      "let l:path = s:root . '/bin/'" \
      "let l:path = '${LanguageClient-neovim-bin}' . '/bin/'"
  '';

  passthru = {
    # needed for the update script
    inherit LanguageClient-neovim-bin;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.LanguageClient-neovim.LanguageClient-neovim-bin";
      extraArgs = [ "--version-regex=(\\d+\\.\\d+\\.\\d+)" ];
    };
  };

  meta = {
    homepage = "https://github.com/autozimu/LanguageClient-neovim/";
    changelog = "https://github.com/autozimu/LanguageClient-neovim/releases/tag/${src.tag}";
    license = lib.licenses.mit;
  };
}
