var gulp = require('gulp');
var concat = require('gulp-concat');
var importCss = require('gulp-import-css');
var uglify = require('gulp-uglify');
var zip = require('gulp-zip');

var dist = 'dist';

gulp.task('default', ['js', 'css']);

gulp.task('js', function () {
  return gulp.src(['src/annotation-widget.js', 'src/annotation-acc-pack.js'])
    .pipe(concat('opentok-annotation.js'))
    .pipe(uglify())
    .pipe(gulp.dest(dist));
});


gulp.task('css', function () {
  return gulp.src('css/annotation.css')
    .pipe(importCss())
    .pipe(gulp.dest(dist));
});


gulp.task('images', function () {
  return gulp.src(
    [
      'images/**',
    ], { base: 'images/' })
    .pipe(gulp.dest('dist/images'));
});

gulp.task('zip', function () {
  return gulp.src(
    [
      'dist/annotation.css',
      'dist/images/**',
      'dist/opentok-annotation.js',
    ], { base: 'dist/' })
  .pipe(zip('opentok-js-annotation-1.0.0.zip'))
  .pipe(gulp.dest(dist));
});

gulp.task('dist', ['js', 'css', 'images', 'zip']);
