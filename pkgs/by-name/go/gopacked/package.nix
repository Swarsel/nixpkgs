{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gopacked";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "tulir";
    repo = "gopacked";
    rev = "v${finalAttrs.version}";
    hash = "sha256-PpOLLqgUQf09grZlJ7bXTxAowzDusmVN8PHfaGlGGQ8=";
  };

  vendorHash = "sha256-ooxVXNbqoh3XX3yFemAyqISNZ+PC8WJUe+ch2OnIdDo=";
  doCheck = false;

  meta = {
    description = "Simple text-based Minecraft modpack manager";
    homepage = finalAttrs.src.meta.homepage;
    license = lib.licenses.agpl3Plus;
    maintainers = [ ];
  };
})
