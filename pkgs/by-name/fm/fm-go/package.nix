{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  finalAttrs = {
    pname = "fm";
    version = "1.2.0";

    src = fetchFromGitHub {
      owner = "mistakenelf";
      repo = "fm";
      rev = "v${finalAttrs.version}";
      hash = "sha256-5+hwubyMgnyYPR7+UdK8VEyk2zo4kniBu7Vj4QarvMg=";
    };

    vendorHash = "sha256-uhrE8ZuUeQSm+Jg1xi83RsBrzjex+aBlElJRT61k0BU=";

    meta = {
      description = "Terminal based file manager";
      homepage = "https://github.com/mistakenelf/fm";
      changelog = "https://github.com/mistakenelf/fm/releases/tag/${finalAttrs.src.rev}";
      license = with lib.licenses; [ mit ];
      maintainers = [ ];
      mainProgram = "fm";
    };
  };
in
buildGoModule finalAttrs
