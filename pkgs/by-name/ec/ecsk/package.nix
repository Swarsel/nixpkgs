{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "ecsk";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "yukiarrr";
    repo = "ecsk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wCv3wyD2KM4Jzawd6Z4JFLCafsDp0W40ygbB05h7r0I=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-Eyqpc7GyG/7u/I4tStADQikxcbIatjeAJN9wUDgzdFY=";
  subPackages = [ "cmd/ecsk" ];

  meta = {
    description = "Interactively call Amazon ECS APIs, copy files between ECS and local, and view logs";
    homepage = "https://github.com/yukiarrr/ecsk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ whtsht ];
    mainProgram = "ecsk";
  };
})
