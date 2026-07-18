{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "easyjson";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "mailru";
    repo = "easyjson";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6QfPxh3Kx9d2a93LsIehgjwkSDMGR8VuSzk58mblvTo=";
  };

  vendorHash = "sha256-BsksTYmfPQezbWfIWX0NhuMbH4VvktrEx06C2Nb/FYE=";
  subPackages = [ "easyjson" ];

  meta = {
    description = "Fast JSON serializer for Go";
    homepage = "https://github.com/mailru/easyjson";
    license = lib.licenses.mit;
    mainProgram = "easyjson";
  };
})
