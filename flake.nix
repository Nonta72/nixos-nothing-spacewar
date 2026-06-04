{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-nothing-spacewar.url = "github:Nonta72/nixos-nothing-spacewar";
  };

  outputs = { self, nixpkgs, nixos-nothing-spacewar, ... }: {
   nixosConfigurations.my-nothing = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Import the Nothing Phone (1) NixOS module.
        nixos-nothing-spacewar.nixosModules.default

        # Import your own custom configuration.
        ./hosts/gnome-mobile/default.nix

    {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.doCheckByDefault = false;
    }

      ];
    };

    # Use the `mkBootImage` and `mkRootfsImage` functions provided by this flake to be able to build
    # boot and rootfs images from your custom configuration, so you can easily flash the first
    # generation of your configuration to your Nothing Phone (1) using `fastboot`.
    packages.aarch64-linux =
      let
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
      in {
        boot-image = nixos-nothing-spacewar.lib.mkBootImage
          self.nixosConfigurations.my-nothing
          pkgs;

        rootfs-image = nixos-nothing-spacewar.lib.mkRootfsImage
          self.nixosConfigurations.my-nothing
          pkgs;

        # Alternatively, if you use Home Manager, use `mkRootfsImageWithHomeManager` to build the
        # rootfs image including Home Manager configuration instead of `mkRootfsImage`:
        #
        # rootfs-image = nixos-nothing-spacewar.lib.mkRootfsImageWithHomeManager
        #   self.nixosConfigurations.my-nothing
        #   pkgs;
      };
  };
}
