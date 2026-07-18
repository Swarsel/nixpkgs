{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uammd";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "RaulPPelaez";
    repo = "UAMMD";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TgGtjERxor/82ueWbl4zW712MyoI7N7f6qloJg+mXRM=";
    fetchSubmodules = true;
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C++14+ header-only fast generic multiscale CUDA Molecular Dynamics framework";
    homepage = "https://github.com/RaulPPelaez/UAMMD";
    changelog = "https://github.com/RaulPPelaez/UAMMD/blob/${finalAttrs.src.tag}/CHANGELOG.txt";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = lib.platforms.linux;
  };
})
