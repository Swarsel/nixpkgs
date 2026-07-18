{
  lib,
  coreutils,
  fetchgit,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "safe-rm";
  version = "1.1.0";

  src = fetchgit {
    url = "https://git.launchpad.net/safe-rm";
    tag = "safe-rm-${finalAttrs.version}";
    sha256 = "sha256-7+4XwsjzLBCQmHDYNwhlN4Yg3eL43GUEbq8ROtuP2Kw=";
  };

  postPatch = ''
    substituteInPlace src/main.rs \
      --replace-fail "/bin/rm" "${coreutils}/bin/rm"
  '';

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-6mPx7qgrsUtjDiFMIL4NTmG9jeC3mBlsQIf/TUB4SQM=";
  # uses lots of absolute paths outside of the sandbox
  doCheck = false;

  postInstall = ''
    installManPage safe-rm.1
  '';

  meta = {
    description = "Tool intended to prevent the accidental deletion of important files";
    homepage = "https://launchpad.net/safe-rm";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
    platforms = lib.platforms.all;
    mainProgram = "safe-rm";
  };
})
