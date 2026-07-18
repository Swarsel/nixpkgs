{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gnostic";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "gnostic";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Wpe+rK4XMfMZYhR1xTEr0nsEjRGkSDA7aiLeBbGcRpA=";
  };

  vendorHash = "sha256-Wyv5czvD3IwE236vlAdq8I/DnhPXxdbwZtUhun+97x4=";
  # some tests are broken and others require network access
  doCheck = false;

  meta = {
    description = "Compiler for APIs described by the OpenAPI Specification with plugins for code generation and other API support tasks";
    homepage = "https://github.com/google/gnostic";
    changelog = "https://github.com/google/gnostic/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
