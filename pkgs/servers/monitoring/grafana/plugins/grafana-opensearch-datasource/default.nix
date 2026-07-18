{ lib, grafanaPlugin }:

grafanaPlugin {
  pname = "grafana-opensearch-datasource";
  version = "2.33.1";

  zipHash = {
    aarch64-darwin = "sha256-QU+0jig8y/+7cshDTJ0J0LGGRVd1uJ5jtSyZcfDjx2k=";
    aarch64-linux = "sha256-3Zm3omgkdYwHe0/39QCR+iwqe0bURKLB1k1cDkUYiAc=";
    x86_64-linux = "sha256-IH1y3tbY++piN+Zlw9Jw2Z7c7pFcPQ7z/X3C0t3iAo8=";
  };

  meta = {
    description = "Empowers you to seamlessly integrate JSON data into Grafana";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagisa ];
    platforms = lib.platforms.unix;
  };
}
