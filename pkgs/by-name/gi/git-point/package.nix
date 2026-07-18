{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "git-point";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "Qyriad";
    repo = "git-point";
    rev = "v0.2.2";
    hash = "sha256-mH++Ddfv+OqjRTTGhagAtnNZpD13OtKhAiGxh7Mu0lY=";
  };

  cargoHash = "sha256-YwinEAJ8djCE2tHp8VcfcyHSa8rUn8RBnsdW0YqIM3o=";

  postInstall = ''
    mkdir -p "$out/share/man/man1"
    "$out/bin/git-point" --mangen > "$out/share/man/man1/git-point.1"
  '';

  meta = {
    description = "Set arbitrary refs without shooting yourself in the foot, a procelain `git update-ref`";
    homepage = "https://github.com/Qyriad/git-point";
    license = [ lib.licenses.mit ];
    sourceProvenance = [ lib.sourceTypes.fromSource ];

    maintainers = [
      lib.maintainers.qyriad
      lib.maintainers.philiptaron
    ];

    platforms = lib.platforms.all;
    mainProgram = "git-point";
  };
}
