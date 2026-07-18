{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule rec {
  pname = "ficsit-cli";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "satisfactorymodding";
    repo = "ficsit-cli";
    tag = "v${version}";
    hash = "sha256-YlwdP7afLsiOaIFKgUIkZXyqTPARgb2Iww/3eFgUcRs=";
  };

  vendorHash = "sha256-3YqOwjCuXF48jsGjwv4mHMoGaiPDgxjzZTcrPAtA7I0=";
  doCheck = false; # Tests make an api call, which always fails in the sandbox.
  commit = "5dc8bdbaf6e8d9b1bcd2895e389d9d072d454e15";

  ldflags = [
    "-X=main.version=v${version}"
    "-X=main.commit=${commit}"
  ];

  meta = {
    description = "CLI tool for managing Satisfactory mods";
    homepage = "https://github.com/satisfactorymodding/ficsit-cli";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      weirdrock
      vilsol
    ];

    mainProgram = "ficsit-cli";
  };
}
