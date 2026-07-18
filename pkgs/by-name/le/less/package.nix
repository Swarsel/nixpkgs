{
  lib,
  stdenv,
  fetchurl,
  ncurses,
  pcre2,
  versionCheckHook,
  # Boolean options
  withSecure ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "less";
  version = "704";

  # `less` is provided by the following sources:
  # - meta.homepage
  # - GitHub: https://github.com/gwsw/less/
  # The releases recommended for general consumption are only those from
  # homepage, and only those not marked as beta.
  src = fetchurl {
    url = "https://www.greenwoodsoftware.com/less/less-${finalAttrs.version}.tar.gz";
    hash = "sha256-IKCworslJfpTx+7pvrhUtMnPFy6rsgmvcCB0NUe/6fs=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  buildInputs = [
    ncurses
    pcre2
  ];

  configureFlags = [
    "--sysconfdir=/etc" # Look for 'sysless' in /etc
    (lib.withFeatureAs true "regex" "pcre2")
    (lib.withFeature withSecure "secure")
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "More advanced file pager than 'more'";
    homepage = "https://www.greenwoodsoftware.com/less/";
    changelog = "https://www.greenwoodsoftware.com/less/news.${finalAttrs.version}.html";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mdaniels5757
      yiyu
    ];

    platforms = lib.platforms.unix;
    mainProgram = "less";
  };
})
