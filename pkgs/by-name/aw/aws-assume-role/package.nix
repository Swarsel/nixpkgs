{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "aws-assume-role";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "remind101";
    repo = "assume-role";
    tag = finalAttrs.version;
    sha256 = "sha256-7+9qi9lYzv1YCFhUyla+5Gqs5nBUiiazhFwiqHzMFd4=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    # Generate with go mod init github.com/remind101/assume-role && go mod tidy
    ./0001-add-go.mod-go.sum.patch
  ];

  vendorHash = "sha256-NIY6w/hQQ357KHEDEHUYVLbkQKsm8FLtRf3/AbbgukA=";

  postInstall = ''
    install -Dm444 -t $out/share/doc/aws-assume-role README.md
  '';

  deleteVendor = true;

  meta = {
    description = "Easily assume AWS roles in your terminal";
    homepage = "https://github.com/remind101/assume-role";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ averyvigolo ];
    platforms = lib.platforms.all;
    mainProgram = "assume-role";
  };
})
