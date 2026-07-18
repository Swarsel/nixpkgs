{
  lib,
  fetchFromGitHub,
  php84,
}:

let
  php = php84;
in
php.buildComposerProject2 (finalAttrs: {
  pname = "postfixadmin";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "postfixadmin";
    repo = "postfixadmin";
    tag = "postfixadmin-${finalAttrs.version}";
    hash = "sha256-mr5FBURTGP2J3JMlcexXjz4GFJNqPR4rZyqHVN7+6iM=";
  };

  vendorHash = "sha256-uyHEfWCC6V4d+ez7FbqBKrh4IfbQ2pgD4UvbdGEfobI=";

  postInstall = ''
    out_dir="$out"/share/php/postfixadmin/

    ln -sf /etc/postfixadmin/config.local.php "$out_dir"
    ln -sf /var/cache/postfixadmin/templates_c "$out_dir"
  '';

  # Upstream does not ship a lock file, we have to maintain our own for now.
  # https://github.com/postfixadmin/postfixadmin/issues/948
  composerLock = ./composer.lock;
  passthru.phpPackage = php;

  meta = {
    description = "Web based virtual user administration interface for Postfix mail servers";
    homepage = "https://postfixadmin.sourceforge.io/";
    changelog = "https://github.com/postfixadmin/postfixadmin/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ yayayayaka ];
    platforms = lib.platforms.all;
  };
})
