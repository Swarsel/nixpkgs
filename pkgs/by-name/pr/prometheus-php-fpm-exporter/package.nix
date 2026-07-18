{
  lib,
  fetchFromGitHub,
  buildGoModule,
  getent,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  prometheus-php-fpm-exporter,
  testers,
}:

buildGoModule rec {
  pname = "php-fpm_exporter";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "hipages";
    repo = "php-fpm_exporter";
    rev = "v${version}";
    hash = "sha256-ggrFnyEdGBoZVh4dHMw+7RUm8nJ1hJXo/fownO3wvzE=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = "sha256-OK36tHkBtosdfEWFPYMtlbzCkh5cF35NBWYyJrb9fwg=";

  postInstall = ''
    installShellCompletion --cmd php-fpm_exporter \
      --bash <($out/bin/php-fpm_exporter completion bash) \
      --fish <($out/bin/php-fpm_exporter completion fish) \
      --zsh <($out/bin/php-fpm_exporter completion zsh)
  '';

  preFixup = ''
    wrapProgram "$out/bin/php-fpm_exporter" \
      --prefix PATH ":" "${lib.makeBinPath [ getent ]}"
  '';

  ldflags = [
    "-X main.version=${version}"
  ];

  passthru = {
    tests = testers.testVersion {
      inherit version;
      command = "php-fpm_exporter version";
      package = prometheus-php-fpm-exporter;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Prometheus exporter for PHP-FPM";
    homepage = "https://github.com/hipages/php-fpm_exporter";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "php-fpm_exporter";
  };
}
