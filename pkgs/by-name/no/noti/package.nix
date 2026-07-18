{
  lib,
  stdenv,
  buildGoModule,
  fetchFromCodeberg,
  installShellFiles,
  llvmPackages,
}:

buildGoModule (finalAttrs: {
  pname = "noti";
  version = "3.8.0";

  src = fetchFromCodeberg {
    owner = "roble";
    repo = "noti";
    tag = finalAttrs.version;
    hash = "sha256-FwOS4ifMiODIzKVQufLhkDYOcmXz9dAfWw+hM3rXT/Y=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.lld ];

  vendorHash = null;

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Work around ld64's libc++ hardening issue.
    # TODO: Remove once #536365 reaches this branch.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  postInstall = ''
    installManPage docs/man/dist/*
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/variadico/noti/internal/command.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/noti" ];

  meta = {
    description = "Monitor a process and trigger a notification";

    longDescription = ''
      Monitor a process and trigger a notification.

      Never sit and wait for some long-running process to finish. Noti can alert
      you when it's done. You can receive messages on your computer or phone.
    '';

    homepage = "https://codeberg.org/roble/noti";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.stites ];
    mainProgram = "noti";
  };
})
