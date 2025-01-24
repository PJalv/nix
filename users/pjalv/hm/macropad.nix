
{ pkgs, lib, ... }:

 pkgs.buildGoModule rec {
    pname = "macro_go";
    version= "0.1.1";

    src = 
    pkgs.fetchFromGitHub {
      owner = "PJalv";
      repo = "macropad";
      rev = "0.1.1";
      hash = "sha256-jDZTHHwQP8N78oNTjFJmUWkhIyagdKIOnOxgX6CzDvk=";
    }+"/macro_go";

  vendorHash = "sha256-wSrY7GIXYcLh6iuhMKu8gqSsXUWj8CdBvMDgT3bH18o=";
  proxyVendor = true;
    meta = {
      description = "PJalv's Macropad Project";
      homepage = "https://github.com/PJalv/macropad";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ PJalv ];
    };
}


