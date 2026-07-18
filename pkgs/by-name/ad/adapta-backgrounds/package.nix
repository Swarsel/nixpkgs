{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adapta-backgrounds";
  version = "0.5.3.1";

  src = fetchFromGitHub {
    owner = "adapta-project";
    repo = "adapta-backgrounds";
    tag = finalAttrs.version;
    sha256 = "04hmbmzf97rsii8gpwy3wkljy5xhxmlsl34d63s6hfy05knclydj";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ glib ];

  meta = {
    description = "Wallpaper collection for adapta-project";
    homepage = "https://github.com/adapta-project/adapta-backgrounds";

    license = with lib.licenses; [
      gpl2
      cc-by-sa-40
    ];

    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.all;
  };
})
