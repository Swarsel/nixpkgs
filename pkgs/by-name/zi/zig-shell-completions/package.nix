{
  lib,
  stdenv,
  fetchFromCodeberg,
  installShellFiles,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zig-shell-completions";
  version = "0-unstable-2025-11-25";

  src = fetchFromCodeberg {
    owner = "ziglang";
    repo = "shell-completions";
    rev = "c2983a75dcbcaf3a1df74ab563a9bd3c8e7f448e";
    hash = "sha256-+sV3BitKhALNQys3u+wsMSHTH3QxoRZ1i75fazIgOjQ=";
  };

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall

    installShellCompletion --bash --name zig.bash _zig.bash
    installShellCompletion --zsh --name _zig _zig

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Shell completions for the Zig compiler";
    homepage = "https://codeberg.org/ziglang/shell-completions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aaronjheng ];
    platforms = lib.platforms.all;
  };
})
