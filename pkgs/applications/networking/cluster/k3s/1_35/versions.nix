{
  chartVersions = import ./chart-versions.nix;
  containerdPackage = "github.com/k3s-io/containerd/v2";
  containerdSha256 = "1i9vkmf3gg34d9hjq15c00frhqxs9cba03zwg7qqq34gkb4qhjch";
  containerdVersion = "2.2.5-k3s2";
  criCtlVersion = "1.35.0-k3s2";
  criDockerdVersion = "v0.3.19-k3s3";
  flannelPluginVersion = "v1.9.0-flannel1";
  flannelVersion = "v0.28.4";
  helmJobVersion = "v0.11.1-build20260615";
  imagesVersions = builtins.fromJSON (builtins.readFile ./images-versions.json);
  k3sCNISha256 = "1ggaz0p1c2k94car9d89a05smz3zx32sxn197b1l5kmjcnzdwadh";
  k3sCNIVersion = "1.9.1-k3s1";
  k3sCommit = "87243446a2c2fe958c31ad552fe38ebf96757b06";
  k3sRepoSha256 = "0hcd2pyd66isnii7x6nbw420n0sc7rwrbws4aayakas1xi0yrkzq";
  k3sRootSha256 = "0yxq2jqqb7flm4rs9dl7fqxba3mmwkmjbc8rx7pgai4qa1lzyigy";
  k3sRootVersion = "0.15.2";
  k3sVendorHash = "sha256-U8JM3CKLGUMWLntMyczrHCW+WMAeiDy2xwzR39InvCM=";
  k3sVersion = "1.35.6+k3s1";
  kubeRouterVersion = "v2.6.3-k3s1";
}
