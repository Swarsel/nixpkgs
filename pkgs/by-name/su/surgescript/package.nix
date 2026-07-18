{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  ninja,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "surgescript";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "alemart";
    repo = "surgescript";
    tag = "v${finalAttrs.version}";
    hash = "sha256-m6H9cyoUY8Mgr0FDqPb98PRJTgF7DgSa+jC+EM0TDEw=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-d0l0xSrhJPIE5dMpEHdRlAMaD3f9x1IGBUpvjcMwDMs=";
      url = "https://github.com/alemart/surgescript/commit/21a9c0696d592b7cc21e07db828fb93a12c95a7e.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    ninja
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Scripting language for games";
    homepage = "https://docs.opensurge2d.org/";
    changelog = "https://github.com/alemart/surgescript/blob/v${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "surgescript";
    downloadPage = "https://github.com/alemart/surgescript";
  };
})
