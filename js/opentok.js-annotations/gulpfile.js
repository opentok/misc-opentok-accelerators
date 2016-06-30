var gulp = require('gulp');
var concat = require('gulp-concat');
var importCss = require('gulp-import-css');
var uglify = require('gulp-uglify');
var zip = require('gulp-zip');

gulp.task('default', ['js', 'css']);
gulp.task('dev', ['js-dev', 'css']);

gulp.task('js', function () {
  return gulp.src('src/*.js')
    .pipe(concat('opentok-annotations.js'))
    .pipe(gulp.dest('dist'));
});


gulp.task('css', function () {
  return gulp.src('css/theme.css')
    .pipe(importCss())
    .pipe(gulp.dest('dist'));
});


gulp.task('images', function () {
  return gulp.src(
    [
      'images/**'
    ], { base: 'images/' })
 .pipe(gulp.dest('dist/images'));
});

gulp.task('zip', function() {
  return gulp.src(
        [
         "dist/theme.css",
         "dist/images/**",
         "dist/opentok-annotations.js"
        ], { base: 'dist/' })
        .pipe(zip('opentok-js-annotations-1.0.0.zip'))
        .pipe(gulp.dest('dist'));
})

gulp.task('dist', ['js', 'css', 'images', 'zip']);
