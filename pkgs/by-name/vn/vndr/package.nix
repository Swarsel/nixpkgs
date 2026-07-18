{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "vndr";
  version = "0.1.2-unstable-2022-12-29";

  src = fetchFromGitHub {
    owner = "LK4D4";
    repo = "vndr";
    rev = "87603e47e8ea2ddac96f508fc9e9d6fc17b198b0";
    hash = "sha256-L7OemAPCv7epOVmjrDDtiGqQqzscm5zj3C6dsZP4uUc=";
  };

  postPatch = ''
    go mod init github.com/LK4D4/vndr
  '';

  vendorHash = null;
  # Tests rely on the 'vndr' binary being in the PATH already.
  doCheck = false;

  meta = {
    description = "Stupid golang vendoring tool, inspired by docker vendor script";
    homepage = "https://github.com/LK4D4/vndr";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      vdemeester
      rvolosatovs
    ];

    mainProgram = "vndr";
  };
}
