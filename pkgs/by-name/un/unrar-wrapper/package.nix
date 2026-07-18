{
  lib,
  fetchFromGitHub,
  python3Packages,
  unar,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "unrar-wrapper";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "openSUSE";
    repo = "unrar_wrapper";
    rev = "unrar_wrapper-${finalAttrs.version}";
    sha256 = "sha256-HjrUif8MrbtLjRQMAPZ/Y2o43rGSDj0HHY4fZQfKz5w=";
  };

  postFixup = ''
    ln -s $out/bin/unrar_wrapper $out/bin/unrar
    rm -rf $out/nix-support/propagated-build-inputs
  '';

  format = "setuptools";

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ unar ]}"
  ];

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Backwards compatibility between unar and unrar";

    longDescription = ''
      unrar_wrapper is a wrapper python script that transforms the basic UnRAR commands
      to unar and lsar calls in order to provide a backwards compatibility.
    '';

    homepage = "https://github.com/openSUSE/unrar_wrapper";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.unix;
  };
})
