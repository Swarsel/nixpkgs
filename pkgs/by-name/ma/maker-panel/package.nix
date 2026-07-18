{
  lib,
  fetchFromGitHub,
  go-md2man,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "maker-panel";
  version = "0.12.4";

  src = fetchFromGitHub {
    owner = "twitchyliquid64";
    repo = "maker-panel";
    rev = finalAttrs.version;
    sha256 = "0dlsy0c46781sb652kp80pvga7pzx6xla64axir92fcgg8k803bi";
  };

  nativeBuildInputs = [
    go-md2man
    installShellFiles
  ];

  cargoHash = "sha256-H4eKZlay0IZ8vAclGruDAyh7Vd6kCvGLxJ5y/cuF+F4=";

  postBuild = ''
    go-md2man --in docs/spec-reference.md --out maker-panel.5
  '';

  postInstall = ''
    installManPage maker-panel.5
  '';

  cargoPatches = [ ./update-gerber-types-to-0.3.patch ];

  meta = {
    description = "Make mechanical PCBs by combining shapes together";
    homepage = "https://github.com/twitchyliquid64/maker-panel";
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
  };
})
