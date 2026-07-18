{
  chartVersions = import ./chart-versions.nix;
  containerdPackage = "github.com/k3s-io/containerd/v2";
  containerdSha256 = "1jzhkh0zg1s2922fkr4r5v1680apafkjqba8ic6br8nc8bk7j4xq";
  containerdVersion = "2.3.2-k3s2";
  criCtlVersion = "1.36.0-k3s1";
  criDockerdVersion = "v0.3.19-k3s5";
  flannelPluginVersion = "v1.9.0-flannel1";
  flannelVersion = "v0.28.4";
  helmJobVersion = "v0.11.1-build20260615";
  imagesVersions = builtins.fromJSON (builtins.readFile ./images-versions.json);
  k3sCNISha256 = "1ggaz0p1c2k94car9d89a05smz3zx32sxn197b1l5kmjcnzdwadh";
  k3sCNIVersion = "1.9.1-k3s1";
  k3sCommit = "01b6f04aaa69e8b09303f0393d4b4f1811da23aa";
  k3sRepoSha256 = "0iqh1hkqfgm9df3bnwi79zxcdk0a9621q451yibr19j58pb76pxv";
  k3sRootSha256 = "0yxq2jqqb7flm4rs9dl7fqxba3mmwkmjbc8rx7pgai4qa1lzyigy";
  k3sRootVersion = "0.15.2";
  k3sVendorHash = "sha256-rwFC0bzUacl5kiQrnpRqqIam+9ADqaPuxLxNBX0wWXY=";
  k3sVersion = "1.36.2+k3s1";
  kubeRouterVersion = "v2.6.3-k3s1";
}
