{
  lib,
  stdenv,
  autoreconfHook,
  fetchFromCodeberg,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libhx";
  version = "5.4";

  src = fetchFromCodeberg {
    owner = "jengelh";
    repo = "libhx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rM0J9IHjxgHsedFiCl6LA54JBHkwuHFYfoFp4j6b3Kw=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    longDescription = ''
      libHX is a C library (with some C++ bindings available) that provides data structures
      and functions commonly needed, such as maps, deques, linked lists, string formatting
      and autoresizing, option and config file parsing, type checking casts and more.
    '';

    homepage = "https://inai.de/projects/libhx/";
    changelog = "https://codeberg.org/jengelh/libhx/src/branch/master/doc/changelog.rst";

    license = with lib.licenses; [
      gpl3
      lgpl21Plus
      mit
    ];

    maintainers = with lib.maintainers; [ chillcicada ];
    platforms = lib.platforms.linux;
  };
})
