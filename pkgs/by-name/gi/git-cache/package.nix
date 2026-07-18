{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "git-cache";
  version = "2018-06-18";

  src = fetchFromGitHub {
    owner = "Seb35";
    repo = "git-cache";
    rev = "354f661e40b358c5916c06957bd6b2c65426f452";
    hash = "sha256-V7rQOy+s9Lzdc+RTA2QGPfyavw4De/qQ+tWrzYtO2qA=";
  };

  installPhase = ''
    install -Dm555 git-cache $out/bin/git-cache
  '';

  dontBuild = true;

  meta = {
    description = "Program to add and manage a system-wide or user-wide cache for remote git repositories";
    homepage = "https://github.com/Seb35/git-cache";
    license = lib.licenses.wtfpl;
    maintainers = with lib.maintainers; [ maxhearnden ];
    platforms = lib.platforms.unix;
    mainProgram = "git-cache";
  };
}
