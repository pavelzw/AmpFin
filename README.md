# AmpFin

Introducing AmpFin, a sleek and intuitive native music client for the Jellyfin media server meticulously crafted for iOS 17, utilizing the power of SwiftUI. AmpFin offers a seamless and intuitive user experience, ensuring optimal performance and functionality.

- **Online & Offline Playback**: Enjoy your favorite tunes anytime, whether you're connected or offline.
- **Explore Artists**: Dive into your music collection effortlessly by browsing through artists.
- **Discover Albums**: Navigate through your albums with ease, enhancing your music exploration.
- **Enjoy your Playlists**: Playlists are fully supported - online & offline
- **Search Your Library**: Quickly find your favorite tracks with our intuitive library search feature.
- **Queue with History**: Take control of your playback experience by creating queues and accessing your listening history.
- **Remote control**: Control AmpFin using another supported Jellyfin client or just take over control of one right inside the app
- **Siri / Spotlight integration**: Play your music using Siri and access your library through Spotlight
- **Automatic updates**: Added a track to a downloaded playlist? AmpFin will download it automatically

## Roadmap

Short term: https://nextcloud.rfk.io/s/iaaAKsad8SxQLfa

- CarPlay
- Rework audio player to use `@Observable`
- Restructure

While i do have plans to support other platforms i will not continue to work on them until at least iOS 18 because i hope that until then SwiftUI is actually usable on the platforms.

## Screenshots

| Library | Album | Player | Queue |
| ------------- | ------------- | ------------- | ------------- |
| <img src="/Screenshots/Library.png?raw=true" alt="Library" width="200"/> | <img src="/Screenshots/Album.png?raw=true" alt="Album" width="200"/> | <img src="/Screenshots/Player.png?raw=true" alt="Player" width="200"/>  | <img src="/Screenshots/Queue.png?raw=true" alt="Queue" width="200"/> 

## Sideload

**Pre built binaries**

Grab the [latest Release](https://github.com/rasmuslos/AmpFin/releases/latest) and install it using your favorite tool like SideStore.

Please not that the pre build binaries lack Siri support because these features either require a paid developer account or cannot be reliably implemented in a way that works with tools like SideStore. For further information see https://github.com/rasmuslos/AmpFin/issues/11

Stripping app extensions is highly recommended, they will not work as intended.

**Build the app yourself**

1. Install Xcode
2. In the `Configuration` directory copy the `Debug.xcconfig.template` file and rename it to `Debug.xcconfig`
3. Change the `DEVELOPMENT_TEAM` to your apple developer team id and `BUNDLE_ID_PREFIX` to a prefix of your liking
4. If you do not have a paid developer account remove the `ENABLE_ALL_FEATURES` compilation condition. Otherwise the app will crash. If you do not intent on developing the app also remove the `DEBUG flag`
5. Connect your iPhone to your Mac & enable developer mode
6. Select your iPhone as the run destination
7. Run the application

Please not that the `DEBUG` configuration is used by default for all builds except archiving and profiling. You have to edit `Release.xcconfig` to update their parameters.

## Licensing & Contributing

AmpFin is licensed under the Mozilla Public License Version 2. Additionally the "Common Clause" applies. This means that you can modify AmpFin, as well as contribute to it, but you are not allowed to distribute the application in binary form. Compiling for your own personal use is not covered by the commons clause and therefore fine. Additionally, prebuilt binaries are available on GitHub for side loading using popular tools like SideStore, etc.

Contributions are welcome, just fork the repository, and open a pull request with your changes. If you want to contribute translations you have to edit `Localizable.xcstrings` in the `iOS` directory, as well as `Localizable.xcstrings` located at `ShelfPlayerKit/Sources/SPBase/Resources` using Xcode. If you want to add a new language add it in the project settings

## Miscellaneous

ShelfPlayer is not endorsed by nor associated with Jellyfin
