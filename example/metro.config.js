const path = require('path');
const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');
const exclusionList =
  require('metro-config/private/defaults/exclusionList').default;

const root = path.resolve(__dirname, '..');
const pkg = require(path.join(root, 'package.json'));

// Peer deps of the library (react, react-native) must resolve to the
// example's copies, never the library's own node_modules — otherwise
// Metro bundles two copies of React and everything breaks.
const modules = Object.keys(pkg.peerDependencies);

const escapeRegExp = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const config = {
  // The library is symlinked from the repo root (file:.. dependency)
  watchFolders: [root],
  resolver: {
    blockList: exclusionList(
      modules.map(
        (m) =>
          new RegExp(
            `^${escapeRegExp(path.join(root, 'node_modules', m))}\\/.*$`
          )
      )
    ),
    extraNodeModules: modules.reduce((acc, name) => {
      acc[name] = path.join(__dirname, 'node_modules', name);
      return acc;
    }, {}),
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
