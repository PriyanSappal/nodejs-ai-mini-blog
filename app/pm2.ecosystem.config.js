module.exports = {
apps: [{
name: 'devops-mini-blog',
script: 'src/index.js',
instances: 1,
exec_mode: 'cluster'
}]
};