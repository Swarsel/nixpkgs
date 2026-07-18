{
  lib,
  fetchFromGitHub,
  installShellFiles,
  libsodium,
  pkg-config,
  ronn,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bupstash";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "andrewchambers";
    repo = "bupstash";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Ekjxna3u+71s1q7jjXp7PxYUQIfbp2E+jAqKGuszU6g=";
  };

  nativeBuildInputs = [
    ronn
    pkg-config
    installShellFiles
  ];

  buildInputs = [ libsodium ];
  cargoHash = "sha256-kWUAI25ag9ghIhn36NF+SunRtmbS0HzsZsxGJujmuG4=";

  postBuild = ''
    RUBYOPT="-KU -E utf-8:utf-8" ronn -r doc/man/*.md
  '';

  postInstall = ''
    installManPage doc/man/*.[1-9]
  '';

  meta = {
    description = "Easy and efficient encrypted backups";
    homepage = "https://bupstash.io";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "bupstash";
  };
})
