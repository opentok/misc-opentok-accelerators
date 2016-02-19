var gulp = require('gulp');
var amdOptimize = require('gulp-amd-optimizer');
var concat = require('gulp-concat');
var amdClean = require('gulp-amdclean');
var Karma = require('karma').Server;
var docco = require('gulp-docco');
var rmrf = require('rimraf');
var yuidoc = require('gulp-yuidoc');
var webserver = require('gulp-webserver');

var requireConfig = {
  baseUrl: __dirname + '/src/'
};

var options = {
  umd: true
};

function runKarma(watch, done) {
  new Karma({
    configFile: __dirname + '/tests/karma.conf.js',
    singleRun: !watch
  }, done).start();
}

gulp.task('demo', function () {
  gulp.src('.')
    .pipe(webserver({
      fallback: 'index.html',
      open: true
    }));
});

gulp.task('bundle', function () {
  return gulp.src('src/opentok-text-chat.js')
    .pipe(amdOptimize(requireConfig, options))
    .pipe(concat('opentok-text-chat.js'))
    .pipe(amdClean.gulp())
    .pipe(gulp.dest('dist'));
});

gulp.task('test', function (done) {
  runKarma(false, done);
});

gulp.task('tdd', function (done) {
  runKarma(true, done);
});

gulp.task('docs:clear', function (done) {
  rmrf('docs/*', done);
});

gulp.task('docs:build-examples', ['docs:clear'], function () {
  return gulp.src('src/ChatWidget.js')
    .pipe(docco())
    .pipe(gulp.dest('docs/examples/'));
});

gulp.task('docs:build-api', ['docs:clear'], function () {
  return gulp.src('src/**/*.js')
    .pipe(yuidoc({}, {
      themedir: 'node_modules/yuidocjs/themes/default'
    }))
    .pipe(gulp.dest('docs'));
});

gulp.task('docs', ['docs:build-examples', 'docs:build-api']);

gulp.task('dist', ['test', 'docs', 'bundle']);

gulp.task('default', ['tdd']);
