const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const elmSource = __dirname + '/'

module.exports = {
  mode: (process.env.NODE_ENV == 'production' ? 'production' : 'development'),
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [ /elm-stuff/, /node_modules/ ],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            cwd: elmSource,
            optimize: (process.env.NODE_ENV == 'production' ? true : false)
          }
        }
      },
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({ template: 'src/index.html' })
  ],
  watchOptions: {
    ignored: [
      /node_modules/,
      /elm-stuff/
    ]
  },
  devServer: {
    clientLogLevel: 'info'
  }
};
