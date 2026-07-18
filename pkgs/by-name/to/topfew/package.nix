{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "topfew";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "timbray";
    repo = "topfew";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P3K3IhgYkrxmEG2l7EQDVWQ+P7fOjUMUFrlAnY+8NmI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = null;

  postInstall = ''
    installManPage doc/tf.1
  '';

  ldflags = [
    "-s"
  ];

  meta = {
    description = "Finds the fields (or combinations of fields) which appear most often in a stream of records";
    homepage = "https://github.com/timbray/topfew";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "tf";
  };
})
