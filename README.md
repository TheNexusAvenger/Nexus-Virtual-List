# Nexus Virtual List
Nexus Virtual List is a utility for displaying long lists of frames
efficiently. This is done by only showing the frames that aren't being
clipped (+ a buffer for scrolling). Automatic scrolling is also supported
(such as global leaderboards or random item displays).

Nexus Virtual List is not tied to any framework, unlike
[`ElementList` in Nexus Plugin Components](https://github.com/TheNexusAvenger/Nexus-Plugin-Components/blob/master/docs/lists.md).

For use with React-Luau, consider [a Luau adaption of FlashList](https://github.com/Neura-Studios/flash-list-lua).

## Limtations
- Only horizontal and vertical lists are supported. Grids aren't supported.
- While the list entries can have any contents based on the data, but
  the entry class must be able to accept the data from any part of the list.
- All of the list entriest must be the same, pre-defined size.

## Usage
Examples can be found in the [`demo` folder](./demo/).

## Contributing
Both issues and pull requests are accepted for this project.

## License
Nexus Virtual List is available under the terms of the MIT License. See
[LICENSE](LICENSE) for details.