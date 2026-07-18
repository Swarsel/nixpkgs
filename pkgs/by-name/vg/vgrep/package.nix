{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go-md2man,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "vgrep";
  version = "2.8.0";

  src = fetchFromGitHub {
    owner = "vrothberg";
    repo = "vgrep";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OQjuNRuzFluZLssM+q+WpoRncdJMj6Sl/A+mUZA7UpI=";
  };

  nativeBuildInputs = [
    go-md2man
    installShellFiles
  ];

  vendorHash = null;

  postBuild = ''
    sed -i '/SHELL= /d' Makefile
    make docs
    installManPage docs/*.[1-9]
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "User-friendly pager for grep/git-grep/ripgrep";
    homepage = "https://github.com/vrothberg/vgrep";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    mainProgram = "vgrep";
  };
})
