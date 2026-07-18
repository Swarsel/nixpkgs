{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "jp";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "jmespath";
    repo = "jp";
    rev = finalAttrs.version;
    hash = "sha256-a3WvLAdUZk+Y+L+opPDMBvdN5x5B6nAi/lL8JHJG/gY=";
  };

  vendorHash = "sha256-K6ZNtART7tcVBH5myV6vKrKWfnwK8yTa6/KK4QLyr00=";

  meta = {
    description = "Command line interface to the JMESPath expression language for JSON";
    homepage = "https://github.com/jmespath/jp";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ cransom ];
    mainProgram = "jp";
  };
})
