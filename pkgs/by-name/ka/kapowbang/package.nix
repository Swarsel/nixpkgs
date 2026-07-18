{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kapowbang";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "BBVA";
    repo = "kapow";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-HUZ1Uf8Z2YbYvqKEUHckKAZ5q+C83zafi3UjemqHFM4=";
  };

  vendorHash = "sha256-vvC9l/6b7AIEmCMVdeKMyi9ThIcAzjtV+uaQ4oSJZuU=";
  doCheck = false;
  subPackages = [ "." ];

  meta = {
    description = "Expose command-line tools over HTTP";
    homepage = "https://github.com/BBVA/kapow";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nilp0inter ];
    mainProgram = "kapow";
  };
})
