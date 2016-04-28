var gulp = require('gulp');
var concat = require('gulp-concat');
var importCss = require('gulp-import-css');
var uglify = require('gulp-uglify');
var zip = require('gulp-zip');
inlineCss = require('gulp-inline-css');

gulp.task('js', function () {
  return gulp.src('src/*')
    .pipe(concat('text-chat-acc-pack.js'))
    .pipe(uglify())
    .pipe(gulp.dest('dist'));
});


gulp.task('css', function () {
  return gulp.src('css/theme.css')
    .pipe(importCss())
    .pipe(gulp.dest('dist'));
});

gulp.task('zip', function (){
  return gulp.src('dist/*')
    .pipe(zip('deliverable.zip'))
    .pipe(gulp.dest('dist'));
});

gulp.task('dist', ['js', 'css', 'zip']);
