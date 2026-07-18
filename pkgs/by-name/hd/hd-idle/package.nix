{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "hd-idle";
  version = "1.22";

  src = fetchFromGitHub {
    owner = "adelolmo";
    repo = "hd-idle";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Q9EMRXzJTkPMMvehrIyiowytjKNfovtiSH4sAO6fzIo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  postInstall = ''
    installManPage debian/hd-idle.8
  '';

  meta = {
    description = "Spins down external disks after a period of idle time";
    homepage = "https://github.com/adelolmo/hd-idle";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.linux;
    mainProgram = "hd-idle";
  };
})
