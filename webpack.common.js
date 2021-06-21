const path = require('path');

module.exports = {
  entry: './src/js/app/app/index.js',
  output: {
    path: path.resolve(__dirname, 'dist/js'),
    filename: 'bundle.js'
  },
  resolve: {
    modules: [path.resolve(__dirname, 'src/js/app'), path.resolve(__dirname, 'src/js/lib'), 'node_modules']
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: [
              [
                '@babel/preset-env',
                {
                  useBuiltIns: 'usage',
                  corejs: 3.9
                }
              ]
            ]
          }
        }
      }
    ]
  }
};
