{
  lib,
  stdenv,
  autoreconfHook,
  fetchzip,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libpff";
  version = "20231205";

  src = fetchzip {
    url = "https://github.com/libyal/libpff/releases/download/${finalAttrs.version}/libpff-alpha-${finalAttrs.version}.tar.gz";
    hash = "sha256-VrdfZRC2iwTfv3YrObQvIH9QZPTi9pUQoAyUcBVJyes=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  meta = {
    description = "Library and tools to access the Personal Folder File (PFF) and the Offline Folder File (OFF) format";
    homepage = "https://github.com/libyal/libpff";
    changelog = "https://github.com/libyal/libpff/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ hacker1024 ];
    downloadPage = "https://github.com/libyal/libpff/releases";
  };
})
