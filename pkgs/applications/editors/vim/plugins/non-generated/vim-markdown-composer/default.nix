{
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  vimUtils,
}:
let
  version = "0-unstable-2022-06-14";
  src = fetchFromGitHub {
    owner = "euclio";
    repo = "vim-markdown-composer";
    rev = "e6f99bc20cfcb277c63041b1f766e6d5940bcc76";
    sha256 = "0ljv8cvca8nk91g67mnzip81say04b1wbj9bzcgzy8m6qkz1r2h3";
    fetchSubmodules = true;
  };

  vim-markdown-composer-bin = rustPlatform.buildRustPackage {
    inherit src version;
    pname = "vim-markdown-composer-bin";
    cargoHash = "sha256-xzlEIaDEYDbxJ6YqzF+lSHcB9O+brClw026YI1YeNUc=";
    # tests require network access
    doCheck = false;
  };
in
vimUtils.buildVimPlugin {
  inherit version src;
  pname = "vim-markdown-composer";

  preFixup = ''
    substituteInPlace "$out"/after/ftplugin/markdown/composer.vim \
      --replace-fail \
      "s:plugin_root . '/target/release/markdown-composer'" \
      "'${vim-markdown-composer-bin}/bin/markdown-composer'"
  '';

  passthru = {
    # needed for the update script
    inherit vim-markdown-composer-bin;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.vim-markdown-composer.vim-markdown-composer-bin";
      extraArgs = [ "--version=branch" ];
    };
  };

  meta = {
    homepage = "https://github.com/euclio/vim-markdown-composer/";
    # rust build error
    broken = true;
  };
}
