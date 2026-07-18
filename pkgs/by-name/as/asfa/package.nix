{
  lib,
  stdenv,
  fetchFromGitHub,
  help2man,
  installShellFiles,
  openssl,
  pkg-config,
  rustPlatform,
}:
let
  version = "0.10.0-1";
  src = fetchFromGitHub {
    owner = "obreitwi";
    repo = "asfa";
    rev = "v${version}";
    hash = "sha256-ARdUlACxmbjmOTuNW2oiVUcfd5agR4rcp9aMQYUAYsw=";
  };
in
rustPlatform.buildRustPackage {
  inherit version src;
  pname = "asfa";

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    help2man
    installShellFiles
    pkg-config
  ];

  buildInputs = [ openssl ];
  cargoHash = "sha256-1aSUH1F6W7+3YQOphmF9olYmPuH/OJ9eIW5j6Jebn+s=";
  # checks disabled because tests need to be run against (docker-based) ephemeral ssh-server
  doCheck = false;

  postInstall = ''
    mkdir -p "man/man1"
    help2man -o "man/man1/asfa.1" "$out/bin/asfa"

    # Generate info about all subcommands except for 'help' (which leads to error)
    "$out/bin/asfa" --help | awk 'enabled && $1 != "help" { print $1 } /^SUBCOMMANDS:$/ { enabled=1 }' \
        | while read -r cmd; do
        help2man \
            "--version-string=${version}" \
            -o "man/man1/asfa-$cmd.1" \
            "$out/bin/asfa $cmd"
    done

    installManPage man/man1/*.1
  '';

  meta = {
    description = "Avoid sending file attachments by uploading them via SSH to a remote site and sharing a publicly-accessible URL with non-guessable (hash-based) prefix instead";
    homepage = "https://github.com/obreitwi/asfa";
    changelog = "https://github.com/obreitwi/asfa/blob/${src.rev}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ obreitwi ];
    mainProgram = "asfa";
  };
}
