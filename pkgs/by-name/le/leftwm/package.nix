{
  lib,
  fetchFromGitHub,
  libx11,
  libxinerama,
  rustPlatform,
}:

let
  rpathLibs = [
    libxinerama
    libx11
  ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "leftwm";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "leftwm";
    repo = "leftwm";
    tag = finalAttrs.version;
    hash = "sha256-eH7HuGZnWlXigTaUAc4S00+uOIEVftnBOD8x03KJLaE=";
  };

  buildInputs = rpathLibs;
  cargoHash = "sha256-nFyhpCp8xsYjRl+2bqPfWzq31pM/yYcDuxkWEjjcqwA=";

  postInstall = ''
    for p in $out/bin/left*; do
      patchelf --set-rpath "${lib.makeLibraryPath rpathLibs}" $p
    done

    install -D -m 0555 leftwm/doc/leftwm.1 $out/share/man/man1/leftwm.1
  '';

  dontPatchELF = true;

  meta = {
    description = "Tiling window manager for the adventurer";
    homepage = "https://github.com/leftwm/leftwm";
    changelog = "https://github.com/leftwm/leftwm/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vuimuich
      yanganto
    ];

    platforms = lib.platforms.linux;
    mainProgram = "leftwm";
  };
})
