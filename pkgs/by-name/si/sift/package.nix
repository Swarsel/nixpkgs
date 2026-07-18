{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "sift";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "svent";
    repo = "sift";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IZ4Hwg5NzdSXtrIDNxtkzquuiHQOmLV1HSx8gpwE/i0=";
  };

  patches = [
    # Add Go Modules support
    (fetchpatch {
      hash = "sha256-mFCEpkgQ8XDPRQ3yKDZ5qY9tKGSuHs+RnhMeAlx33Ng=";
      url = "https://github.com/svent/sift/commit/b56fb3d0fd914c8a6c08b148e15dd8a07c7d8a5a.patch";
    })
  ];

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-y883la4R4jhsS99/ohgBC9SHggybAq9hreda6quG3IY=";

  postInstall = ''
    installShellCompletion --cmd sift --bash sift-completion.bash
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Fast and powerful alternative to grep";
    homepage = "https://sift-tool.org";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ viraptor ];
    mainProgram = "sift";
  };
})
