{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  libgit2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  vimUtils,
  zlib,
}:

let
  version = "0.55";

  src = fetchFromGitHub {
    owner = "liuchengxu";
    repo = "vim-clap";
    tag = "v${version}";
    hash = "sha256-vtIA2URex7DOBIZ9KW++/ziqhVd/GDJOKYTUULdMqGc=";
  };

  meta = {
    description = "Modern performant fuzzy picker for Vim and NeoVim";
    homepage = "https://github.com/liuchengxu/vim-clap";
    changelog = "https://github.com/liuchengxu/vim-clap/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "maple";
  };

  maple = rustPlatform.buildRustPackage {
    inherit version src meta;
    pname = "maple";
    strictDeps = false;

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      libgit2
      zlib
    ];

    cargoHash = "sha256-RMDlLpPWDLHCRWLz7NAAQhp6FhKA7aNYqx9MCqR8vYM=";

    cargoPatches = [
      # TODO: remove after next release
      # https://github.com/liuchengxu/vim-clap/issues/1121
      (fetchpatch2 {
        hash = "sha256-FvGuSFHMOprPSUlR82SR/IMNDd3RaGECQm2wfPCOW4Y=";
        url = "https://github.com/liuchengxu/vim-clap/commit/b95d4a3f9371271096553df1240b3f59a2dc99ec.patch?full_index=1";
      })
    ];
  };
in

vimUtils.buildVimPlugin {
  inherit version src meta;
  pname = "vim-clap";
  strictDeps = false;

  postInstall = ''
    ln -s ${maple}/bin/maple $out/bin/maple
  '';

  passthru = {
    inherit maple;

    updateScript = nix-update-script {
      attrPath = "vimPlugins.vim-clap.maple";
    };
  };
}
