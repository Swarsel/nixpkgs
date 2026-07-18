{
  lib,
  stdenv,
  fetchurl,
  gitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "rubygems";
  version = "3.7.2";

  src = fetchurl {
    url = "https://rubygems.org/rubygems/rubygems-${version}.tgz";
    hash = "sha256-7+zgEiWlMvS1LPh2TSCgDg0p7W+Fsz2TAt9IlqkPpas=";
  };

  patches = [
    ./0001-add-post-extract-hook.patch
    ./0002-binaries-with-env-shebang.patch
    ./0003-gem-install-default-to-user.patch
  ];

  installPhase = ''
    runHook preInstall
    cp -r . $out
    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    ignoredVersions = "(pre|alpha|beta|rc|bundler).*";
    rev-prefix = "v";
    url = "https://github.com/rubygems/rubygems.git";
  };

  meta = {
    description = "Package management framework for Ruby";
    homepage = "https://rubygems.org/";
    changelog = "https://github.com/rubygems/rubygems/blob/v${version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # or
      ruby
    ];

    maintainers = with lib.maintainers; [ zimbatm ];
    mainProgram = "gem";
  };
}
