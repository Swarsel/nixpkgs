{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bash,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prctl";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "hikerockies";
    repo = "prctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1b8SO70mp0ACL3hw/iwKpPUpI5G7hF7l84hlSDHB2oA=";
  };

  patches = [
    # Eliminate unsafe strcpy() calls,
    # cf. <https://github.com/hikerockies/prctl/pull/1>
    ./prctl-strcpy-overflow.patch

    # Correct option parsing,
    # cf. <https://github.com/hikerockies/prctl/pull/2>
    ./prctl-getopt.patch
  ];

  postPatch = ''
    substituteInPlace prctl.c \
      --replace-fail '"/bin/bash"' '"${lib.getExe bash}"'
  '';

  strictDeps = true;
  nativeBuildInputs = [ autoreconfHook ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to query and modify process behaviour";
    homepage = "https://tracker.debian.org/pkg/prctl";
    changelog = "https://github.com/hikerockies/prctl/blob/v${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mvs ];
    platforms = lib.platforms.linux;
    mainProgram = "prctl";
  };
})
