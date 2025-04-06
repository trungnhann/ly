const execSync = require('child_process').execSync;
const activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf-8' }).trim();

module.exports = {
  content: [
    // ActiveAdmin paths
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,

    './app/admin/**/*.{arb,erb,html,rb}',
    './app/views/**/*.{arb,erb,html,rb}',
    './app/views/layouts/**/*.{erb,html}',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/assets/stylesheets/**/*.css',
    './app/components/**/*.{html,erb,rb}'
  ],
  darkMode: 'selector',
  theme: {
    extend: {
      colors: {
        eb6222: '#eb6222',
        'eb6222-hover': '#ff7f3e',
      },
    },
  },
  plugins: [
    require('@activeadmin/activeadmin/plugin')
  ],
}
