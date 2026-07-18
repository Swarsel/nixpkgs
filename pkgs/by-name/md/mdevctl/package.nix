{
  lib,
  docutils,
  fetchCrate,
  installShellFiles,
  rustPlatform,
  udevCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mdevctl";
  version = "1.4.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-Zh+Dj3X87tTpqT/weZMpf7f3obqikjPy9pi50ifp6wQ=";
  };

  # https://github.com/mdevctl/mdevctl/issues/111
  patches = [
    ./script-dir.patch
  ];

  nativeBuildInputs = [
    docutils
    installShellFiles
    udevCheckHook
  ];

  cargoHash = "sha256-LG5UaSUTF6pVx7BBLiZ/OmAZNCKswFlTqHymg3bDkuc=";

  postInstall = ''
    ln -s mdevctl $out/bin/lsmdev

    install -Dm444 60-mdevctl.rules -t $out/lib/udev/rules.d

    installManPage $releaseDir/build/mdevctl-*/out/mdevctl.8
    ln -s mdevctl.8 $out/share/man/man8/lsmdev.8

    installShellCompletion $releaseDir/build/mdevctl-*/out/{lsmdev,mdevctl}.bash
  '';

  doInstallCheck = true;

  meta = {
    description = "Mediated device management utility for linux";
    homepage = "https://github.com/mdevctl/mdevctl";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ edwtjo ];
    platforms = lib.platforms.linux;
  };
})
