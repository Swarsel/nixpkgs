{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  bash,
  coreutils,
  doas-sudo-shim,
  gawk,
  glibc,
  makeBinaryWrapper,
  runCommand,
  util-linux,
}:

stdenv.mkDerivation rec {
  pname = "doas-sudo-shim";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "doas-sudo-shim";
    rev = "v${version}";
    sha256 = "sha256-USSakVUzCbUY1DJLmDCiwdq/xjOwwnm3VtXBBeXeV1A=";
  };

  nativeBuildInputs = [
    asciidoctor
    makeBinaryWrapper
  ];

  buildInputs = [
    bash
    coreutils
    gawk
    glibc
    util-linux
  ];

  postInstall = ''
    wrapProgram $out/bin/sudo \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          coreutils
          gawk
          glibc
          util-linux
        ]
      }
  '';

  dontBuild = true;
  dontConfigure = true;

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX=\"\""
  ];

  passthru.tests = {
    helpTest = runCommand "${pname}-helpTest" { } ''
      ${doas-sudo-shim}/bin/sudo -h > $out
      grep -q "Execute a command as another user using doas(1)" $out
    '';
  };

  meta = {
    description = "Shim for the sudo command that utilizes doas";
    homepage = "https://github.com/jirutka/doas-sudo-shim";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ dsuetin ];
    platforms = lib.platforms.linux;
    mainProgram = "sudo";
  };
}
